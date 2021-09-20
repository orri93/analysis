#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>

/* For TCP example See */
/* https://docs.microsoft.com/en-us/windows/win32/winsock/complete-server-code */

#ifdef _WIN32
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>   /* For getaddrinfo etc */
#else
#endif

#include <genann.h>

#define BUFFER_LENGTH 512
#define DEFAULT_TCP_PORT "54321"

#define DEFAULT_INPUT_COUNT 64
#define DEFAULT_OUTPUT_COUNT 2
#define DEFAULT_HIDDEN_LAYER_COUNT 16
#define DEFAULT_HIDDEN_NEURON_COUNT DEFAULT_INPUT_COUNT
#define DEFAULT_TRAIN_COUNT 1
#define DEFAULT_LEARNING_RATE 0.01

/* Usage nntcpserver [Input Count] [Hidder Layer Count] [Learning Rate] [Hidden Neuron Count] */

struct input_message {
  double value;
  int classification;
  int training;
};

static void parse_arguments(int argc, char* argv[]);

static void parse_input(struct input_message* input);
static void parse_classification(double* output_array, int classification);
static int parse_guess(const double* guess_array);

static int maximum_index(const double* number, int count);

static int network_initialize();
static int network_resolve_endpoint();
static SOCKET network_create_connect_socket();
static int network_bind();
static int network_listen();
static SOCKET network_accept();
static int network_shutdown_socket(SOCKET s);
static void network_shutdown_client_socket(SOCKET* sp);
static void network_close_socket(SOCKET* sp);
static void network_close_connect_socket();
static void network_free_endpoint();
static void network_shutdown();

static void nn_tcp_server_shutdown();

static int network_initialized = 0;
static struct addrinfo* endpoint = 0;
static SOCKET connect_socket = INVALID_SOCKET;

static int input_count = DEFAULT_INPUT_COUNT;
static int hidden_layer_count = DEFAULT_HIDDEN_LAYER_COUNT;
static int hidden_neuron_count = DEFAULT_HIDDEN_NEURON_COUNT;
static double learning_rate = DEFAULT_LEARNING_RATE;

static char buffer[BUFFER_LENGTH];

int main(int argc, char *argv[]) {
  int i, recvres, sendres, netres, resplength, training = -1, classification = -1, inputcount = 0, result = EXIT_SUCCESS;
  int guesscount = 0, correctcount = 0;
  double correctratio;
  double nnoutput[DEFAULT_OUTPUT_COUNT];
  double* nninput = 0;
  const double* guess;
  SOCKET client_socket = INVALID_SOCKET;
  struct input_message input;
  genann* ann = 0;
  
  printf("Starting the Neural Network TCP Server on port " DEFAULT_TCP_PORT "\n");

  parse_arguments(argc, argv);

  nninput = malloc(sizeof(double) * input_count);
  if (!nninput) {
    fprintf(stderr, "Out of memory for input\n");
    goto exit_failure;
  }

  ann = genann_init(
    input_count,
    hidden_layer_count,
    hidden_neuron_count,
    DEFAULT_OUTPUT_COUNT);
  if (!ann) {
    fprintf(stderr, "Failed to initialize the Neural Network\n");
    goto exit_failure;
  }

  network_initialized = network_initialize();
  if (!network_initialized) {
    goto exit_failure;
  }

  if (!network_resolve_endpoint()) {
    goto exit_failure;
  }

  connect_socket = network_create_connect_socket();
  if (connect_socket == INVALID_SOCKET) {
    goto exit_failure;
  }

  if (!network_bind()) {
    goto exit_failure;
  }

  if (!network_listen()) {
    goto exit_failure;
  }

  printf("Waiting for connection\n");

  client_socket = network_accept();
  if (client_socket == INVALID_SOCKET) {
    goto exit_failure;
  }
  
  /* No longer need server socket */
  network_close_connect_socket();

  /* Receive until the peer shuts down the connection */
  do {
    recvres = recv(client_socket, buffer, BUFFER_LENGTH - 1, 0);
    if (recvres > 0) {
      netres = -2;
      buffer[recvres] = '\0';
      parse_input(&input);
      if (training != input.training) {
        if (training) {
          printf("Switching to training (from %d to %d)\n", training, input.training);
        } else {
          printf("Switching to predicting (from %d to %d)\n", training, input.training);
        }
        training = input.training;
        inputcount = 0;
      }
      if (training && classification != input.classification) {
        classification = input.classification;
        //printf("Switching to classification of %d\n", classification);
        inputcount = 0;
      }
      // printf("%f ", input.value);
      nninput[inputcount] = input.value;
      inputcount++;
      if (inputcount >= input_count) {
        // printf("\n");
        if (training) {
          // printf("Training with classification of %d\n", classification);
          parse_classification(nnoutput, classification);
          for (i = 0; i < DEFAULT_TRAIN_COUNT; i++) {
            genann_train(ann, nninput, nnoutput, learning_rate);
          }
          netres = -1;
        } else {
          guess = genann_run(ann, nninput);
          netres = parse_guess(guess);
          printf("Predicting ");
          for (i = 0; i < DEFAULT_OUTPUT_COUNT; i++) {
            if (i > 0) {
              printf(",");
            }
            printf("%f", guess[i]);
          }
          if (netres == input.classification) {
            correctcount++;
            printf(" with correct classification of %d\n", netres);
          } else {
            printf(" with incorrect classification of %d being %d\n", netres, input.classification);
          }
          guesscount++;
        }
        inputcount = 0;
      }
      resplength = sprintf_s(buffer, BUFFER_LENGTH, "%d", netres);
      sendres = send(client_socket, buffer, resplength, 0);
      if (sendres == SOCKET_ERROR) {
        fprintf(stderr, "Send failed with error: %ld\n", WSAGetLastError());
        goto exit_failure;
      }
    } else if (recvres == 0) {
      printf("Connection closing\n");
    } else {
      fprintf(stderr, "Reciving failed with error: %d\n", WSAGetLastError());
      goto exit_failure;
    }
  } while (recvres > 0);

  correctratio = ((double)correctcount) / ((double)guesscount);
  printf("Correct %d time of %d guesses with ratio of %f\n", correctcount, guesscount, correctratio);

  goto exit_main;

exit_failure:
  result = EXIT_FAILURE;

exit_main:
  network_shutdown_client_socket(&client_socket);

  nn_tcp_server_shutdown();

  if (ann) {
    genann_free(ann);
    ann = 0;
  }

  if (nninput) {
    free(nninput);
    nninput = 0;
  }

  return result;
}

void parse_arguments(int argc, char* argv[]) {
  if (argc > 1) {
    input_count = atoi(argv[1]);
    hidden_neuron_count = input_count;
    printf("Input count is specified as %d\n", input_count);
  } else {
    printf("Using default input count of %d\n", input_count);
  }
  if (argc > 2) {
    hidden_layer_count = atoi(argv[2]);
    printf("Hidden layer count is specified as %d\n", hidden_layer_count);
  } else {
    printf("Using default hidden layer count of %d\n", hidden_layer_count);
  }
  if (argc > 3) {
    learning_rate = atof(argv[3]);
    printf("Learning rate is specified as %f\n", learning_rate);
  } else {
    printf("Using default learning rate of %f\n", learning_rate);
  }
  if (argc > 4) {
    hidden_neuron_count = atoi(argv[4]);
    printf("Hidden neuron count is specified as %d\n", hidden_neuron_count);
  } else {
    printf("Using default hidden neuron count of %d\n", hidden_neuron_count);
  }
}

void parse_input(struct input_message* input) {
  char* split;

  split = strtok(buffer, ",");
  input->value = atof(split);
  split = strtok(0, ",");
  input->classification = atoi(split);
  split = strtok(0, ",");
  input->training = atoi(split);
}

void parse_classification(double* output_array, int classification) {
  memset(output_array, 0, sizeof(double) * DEFAULT_OUTPUT_COUNT);
  output_array[classification] = 1.0;
}

int parse_guess(const double* guess_array) {
  return maximum_index(guess_array, DEFAULT_OUTPUT_COUNT);
}

int maximum_index(const double* number, int count) {
  int i;
  int index = -1;
  double value = -FLT_MAX;
  for (i = 0; i < count; ++i) {
    if (number[i] > value) {
      index = i;
      value = number[i];
    }
  }
  return index;
}

int network_initialize() {
  int result;
  WSADATA wsaData;
  /* Initialize Winsock */
  result = WSAStartup(MAKEWORD(2, 2), &wsaData);
  switch (result) {
  case 0:
    return 1;
  case WSASYSNOTREADY:
    fprintf(stderr, "Initializing Winsock failed because the underlying network subsystem is not ready\n");
    break;
  case WSAVERNOTSUPPORTED:
    fprintf(stderr, "Initializing Winsock failed because the Windows Sockets version is not supported\n");
    break;
  case WSAEINPROGRESS:
    fprintf(stderr, "Initializing Winsock failed because a blocking Sockets operation is in progress\n");
    break;
  case WSAEPROCLIM:
    fprintf(stderr, "Initializing Winsock failed because a limit on the supported task count has been reached\n");
    break;
  case WSAEFAULT:
    fprintf(stderr, "Initializing Winsock failed because of an invalid data pointer\n");
    break;
  default:
    fprintf(stderr, "Initializing Winsock failed with error: %d\n", result);
    break;
  }
  return 0;
}

int network_resolve_endpoint() {
  int result;
  struct addrinfo hints;

  memset(&hints, 0, sizeof(struct addrinfo));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = IPPROTO_TCP;
  hints.ai_flags = AI_PASSIVE;

  /* Resolve the server addressand port */
  result = getaddrinfo(NULL, DEFAULT_TCP_PORT, &hints, &endpoint);
  switch (result) {
  case 0:
    return 1;
  case EAI_AGAIN:
    fprintf(stderr, "Resolving endpoint failed because of a temporary failure\n");
    break;
  case EAI_BADFLAGS:
    fprintf(stderr, "Resolving endpoint failed because of an invalid value\n");
    break;
  case EAI_FAIL:
    fprintf(stderr, "Resolving endpoint failed because of a nonrecoverable failure\n");
    break;
  case EAI_FAMILY:
    fprintf(stderr, "Resolving endpoint failed because the family parameter is not supported\n");
    break;
  case EAI_MEMORY:
    fprintf(stderr, "Resolving endpoint failed because of a memory allocation failure\n");
    break;
  case EAI_NONAME:
    fprintf(stderr, "Resolving endpoint failed because the name does not resolve or is not provided\n");
    break;
  case EAI_SERVICE:
    fprintf(stderr, "Resolving endpoint failed because the name parameter is not supported\n");
    break;
  case EAI_SOCKTYPE:
    fprintf(stderr, "Resolving endpoint failed because the type parameter is not supported\n");
    break;
  default:
    fprintf(stderr, "Resolving endpoint failed with error: %d\n", result);
    break;
  }
  return 0;
}

SOCKET network_create_connect_socket() {
  SOCKET result;
  /* Create a SOCKET for connecting to server */
  result = socket(endpoint->ai_family, endpoint->ai_socktype, endpoint->ai_protocol);
  if (result == INVALID_SOCKET) {
    fprintf(stderr, "Creating connecting socket failed with error: %ld\n", WSAGetLastError());
  }
  return result;
}

int network_bind() {
  int result;
  /* Setup the TCP listening socket */
  result = bind(connect_socket, endpoint->ai_addr, (int)(endpoint->ai_addrlen));
  if (result != SOCKET_ERROR) {
    return 1;
  } else {
    fprintf(stderr, "Binding failed with error: %ld\n", WSAGetLastError());
    return 0;
  }
}

int network_listen() {
  int result;
  result = listen(connect_socket, SOMAXCONN);
  if (result != SOCKET_ERROR) {
    return 1;
  } else {
    fprintf(stderr, "Listen failed with error: %ld\n", WSAGetLastError());
    return 0;
  }
}

SOCKET network_accept() {
  SOCKET result;
  /* Accept a client socket */
  result = accept(connect_socket, NULL, NULL);
  if (result == INVALID_SOCKET) {
    fprintf(stderr, "Accepting a connection failed with error: %ld\n", WSAGetLastError());
  }
  return result;
}

int network_shutdown_socket(SOCKET s) {
  int result;
  /* shutdown the connection since we're done */
  result = shutdown(s, SD_SEND);
  if (result != SOCKET_ERROR) {
    return 1;
  } else {
    fprintf(stderr, "Shutting down a socket failed with error: %ld\n", WSAGetLastError());
    return 0;
  }
}

void network_shutdown_client_socket(SOCKET* sp) {
  if (*sp != INVALID_SOCKET) {
    network_shutdown_socket(*sp);
    network_close_socket(sp);
  }
}

void network_close_socket(SOCKET* sp) {
  if (*sp != INVALID_SOCKET) {
    closesocket(*sp);
    *sp = INVALID_SOCKET;
  }
}

void network_close_connect_socket() {
  network_close_socket(&connect_socket);
}

void network_free_endpoint() {
  if (endpoint) {
    freeaddrinfo(endpoint);
    endpoint = 0;
  }
}

void network_shutdown() {
  if (network_initialized) {
    WSACleanup();
    network_initialized = 0;
  }
}

void nn_tcp_server_shutdown() {
  network_close_connect_socket();
  network_free_endpoint();
  network_shutdown();
}
