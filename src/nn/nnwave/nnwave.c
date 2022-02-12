#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <genann.h>

#define DEFAULT_INPUT_COUNT 64
#define DEFAULT_OUTPUT_COUNT 2
#define DEFAULT_HIDDEN_LAYER_COUNT 16
#define DEFAULT_HIDDEN_NEURON_COUNT DEFAULT_INPUT_COUNT
#define DEFAULT_TRAIN_COUNT 10
#define DEFAULT_LEARNING_RATE 0.01

#define TRAIN_CYCLES 128

#define PREDICT_CYCLES 64

#define FUNCTION_COUNT 64

#define FUNCTION_RANGE 4 * M_PI
#define FUNCTION_STEP FUNCTION_RANGE / DEFAULT_INPUT_COUNT

#define START_RANGE 2 * M_PI
#define START_STEP START_RANGE / FUNCTION_COUNT

static void set_classification(int classification);

static double square(double t);

static void populate_with_sin(double at);
static void populate_with_square(double at);

static double nninput[DEFAULT_INPUT_COUNT];
static double nnoutput[DEFAULT_OUTPUT_COUNT];

static genann* ann = 0;

int main(int argc, char* argv[]) {
  int c, i, result = EXIT_SUCCESS;
  const double* guess;
  double at;

  printf("Starting the Neural Network Wave Experiment\n");

  ann = genann_init(
    DEFAULT_INPUT_COUNT,
    DEFAULT_HIDDEN_LAYER_COUNT,
    DEFAULT_HIDDEN_NEURON_COUNT,
    DEFAULT_OUTPUT_COUNT);

  if (!ann) {
    fprintf(stderr, "Failed to initialize the Neural Network\n");
    goto exit_failure;
  }

  printf("Training");

  for (c = 0; c < TRAIN_CYCLES; c++) {
    at = -START_RANGE;
    while (at < 0.0) {
      populate_with_sin(at);
      set_classification(0);
      for (i = 0; i < DEFAULT_TRAIN_COUNT; i++) {
        genann_train(ann, nninput, nnoutput, DEFAULT_LEARNING_RATE);
      }

      populate_with_square(at);
      set_classification(1);
      for (i = 0; i < DEFAULT_TRAIN_COUNT; i++) {
        genann_train(ann, nninput, nnoutput, DEFAULT_LEARNING_RATE);
      }

      at += START_STEP;
    }
  }

  for (c = 0; c < PREDICT_CYCLES; c++) {
    at = -START_RANGE;
    while (at < 0.0) {
      populate_with_sin(at);
      guess = genann_run(ann, nninput);
      printf("%f", at);
      for (i = 0; i < DEFAULT_OUTPUT_COUNT; i++) {
        printf(",%f", guess[i]);
      }
      printf("\n");

      at += START_STEP;
    }
  }

exit_failure:
  result = EXIT_FAILURE;

exit_main:
  if (ann) {
    genann_free(ann);
    ann = 0;
  }

  return result;
}

void set_classification(int classification) {
  memset(nnoutput, 0, sizeof(double) * DEFAULT_OUTPUT_COUNT);
  nnoutput[classification] = 1.0;
}

double square(double t) {
  return copysign(1.0, sin(t));
}

void populate_with_sin(double at) {
  int i;
  for (i = 0; i < DEFAULT_INPUT_COUNT; i++) {
    nninput[i] = sin(at);
    at += FUNCTION_STEP;
  }
}

void populate_with_square(double at) {
  int i;
  for (i = 0; i < DEFAULT_INPUT_COUNT; i++) {
    nninput[i] = square(at);
    at += FUNCTION_STEP;
  }
}
