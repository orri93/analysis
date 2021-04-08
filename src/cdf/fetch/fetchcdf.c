/*
 *  
 *  https://github.com/curl/curl/blob/master/docs/examples/ftpsget.c
 */

#include <stdlib.h>
#include <stdio.h>

#include <curl/curl.h>

#define URL "ftp://spdf.gsfc.nasa.gov/pub/solar-orbiter/helio1day/solo_helio1day_position_20200211_v01.cdf"

static size_t curl_fwrite_cb(
  void *buffer,
  size_t size,
  size_t nmemb,
  void *data) {
  return fwrite(buffer, size, nmemb, stdout);
}

int main(int argc, char* argv[]) {
  int mr = EXIT_FAILURE;
  CURL* curl = NULL;
  CURLcode gicc, cc;

  printf("Starting Fetch and Convert CDF files\n");

  gicc = curl_global_init(CURL_GLOBAL_DEFAULT);
  if (gicc == CURLE_OK) {
    curl = curl_easy_init();
    if (curl) {
      cc = curl_easy_setopt(
        curl,
        CURLOPT_URL,
        URL);
      if (cc != CURLE_OK) {
        fprintf(
          stderr,
          "Curl easy set option for '%s' failed: %s (%d)\n",
          URL,
          curl_easy_strerror(cc),
          cc);
        goto fcdf_ex_exit;
      }
      cc = curl_easy_setopt(
        curl,
        CURLOPT_WRITEFUNCTION,
        curl_fwrite_cb);
      if (cc != CURLE_OK) {
        fprintf(
          stderr,
          "Curl easy set option for ftps call back function failed: %s (%d)\n",
          curl_easy_strerror(cc),
          cc);
        goto fcdf_ex_exit;
      }
      cc = curl_easy_setopt(
        curl,
        CURLOPT_WRITEDATA,
        NULL);
      if (cc != CURLE_OK) {
        fprintf(
          stderr,
          "Curl easy set option for ftps call back data failed: %s (%d)\n",
          curl_easy_strerror(cc),
          cc);
        goto fcdf_ex_exit;
      }
      cc = curl_easy_setopt(
        curl,
        CURLOPT_USE_SSL,
        CURLUSESSL_ALL);
      if (cc != CURLE_OK) {
        fprintf(
          stderr,
          "Curl easy set option for ftps SSL failed: %s (%d)\n",
          curl_easy_strerror(cc),
          cc);
        goto fcdf_ex_exit;
      }
      cc = curl_easy_perform(curl);
      if (cc != CURLE_OK) {
        fprintf(
          stderr,
          "Curl easy ftps perform failed: %s (%d)\n",
          curl_easy_strerror(cc),
          cc);
        goto fcdf_ex_exit;
      }
    } else {
      fprintf(stderr, "Curl easy initialize failed\n");
      goto fcdf_ex_exit;
    }
  } else {
    fprintf(
      stderr,
      "Curl global initialize failed: %s (%d)\n",
      curl_easy_strerror(gicc),
      gicc);
    goto fcdf_ex_exit;
  }

  mr = EXIT_SUCCESS;
fcdf_ex_exit:
  if (curl) {
    curl_easy_cleanup(curl);
    curl = NULL;
  }
  if (gicc == CURLE_OK) {
    curl_global_cleanup();
  }

  return mr;
}
