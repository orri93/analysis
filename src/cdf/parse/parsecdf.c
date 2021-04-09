#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

#include <cdf.h>

#define PARSE_CDF_FIELD_NAME "FIELDNAM"

static bool welcome();
static bool display_document_information(CDFid id, const char* fn);
static bool display_document_attributes(CDFid id, long num);
static bool display_variable_information(CDFid id, const char* vn);
static bool display_variable_values(CDFid id, const char* vn);

int main(int argc, char* argv[]) {
  CDFstatus cdfs;           /* CDF returned status code */
  CDFid     cdfid = NULL;   /* CDF identifier.          */
  char      cdfst[CDF_STATUSTEXT_LEN + 1];
  char*     fn = NULL;

  long      numdims;
  long      dimsizes[CDF_MAX_DIMS];
  long      encoding;
  long      majority;
  long      maxrec;
  long      numvars;
  long      numattrs;

  int mr = EXIT_FAILURE;

  if (!welcome()) {
    goto pcdf_exit;
  }

  if (argc > 1) {
    fn = argv[1];
    cdfs = CDFopen(fn, &cdfid);
    if (cdfs == CDF_OK) {
      if (!display_document_information(cdfid, fn)) {
        goto pcdf_exit;
      }
      cdfs = CDFinquire(
        cdfid,
        &numdims,
        dimsizes,
        &encoding,
        &majority,
        &maxrec,
        &numvars,
        &numattrs);
      if (cdfs == CDF_OK) {
        printf(
          "CDF inquire\n"
          "  Number of dimensions: %d\n"
          "  Encoding: %d\n"
          "  Majority: %d\n"
          "  Maximum Record: %d\n"
          "  Number of variables: %d\n"
          "  Number of attributes: %d\n",
          numdims,
          encoding,
          majority,
          maxrec,
          numvars,
          numattrs);
      } else {
        CDFerror(cdfs, cdfst);
        fprintf(
          stderr,
          "CDF inquire failed: %s (%d)\n",
          cdfst,
          cdfs);
        goto pcdf_exit;
      }
      if (!display_document_attributes(cdfid, numattrs)) {
        goto pcdf_exit;
      }
      if (!display_variable_values(cdfid, "RAD_AUX")) {
        goto pcdf_exit;
      }
    } else {
      CDFerror(cdfs, cdfst);
      fprintf(
        stderr,
        "CDF Opening '%s' failed: %s (%d)\n",
        fn,
        cdfst,
        cdfs);
      goto pcdf_exit;
    }
  } else {
    fprintf(stderr, "No CDF file name given\n");
    goto pcdf_exit;
  }

  mr = EXIT_SUCCESS;
pcdf_exit:
  if (cdfid != NULL) {
    CDFclose(&cdfid);
    cdfid = NULL;
  }
  return mr;
}

bool welcome() {
  CDFstatus cdfs;
  long version = -1;
  long release = -1;
  long increment = -1;
  char subincrement = '\0';
  char copyrighttext[CDF_COPYRIGHT_LEN + 1];
  cdfs = CDFgetLibraryCopyright(copyrighttext);
  if (cdfs == CDF_OK) {
    cdfs = CDFgetLibraryVersion(&version, &release, &increment, &subincrement);
    if (cdfs == CDF_OK) {
      printf(
        "Using CDF library version %d.%d.%d.%d. Copyright information: %s\n",
        version,
        release,
        increment,
        subincrement,
        copyrighttext);
      return true;
    } else {
      fprintf(
        stderr,
        "CDF getting library version failed with code: %d\n",
        cdfs);
    }
  } else {
    fprintf(
      stderr,
      "CDF getting library copyright failed with code: %d\n",
      cdfs);
  }

  return false;
}

bool display_document_information(CDFid id, const char* fn) {
  CDFstatus cdfs;
  long version;
  long release;
  char copyrighttext[CDF_COPYRIGHT_LEN + 1];
  cdfs = CDFdoc(id, &version, &release, copyrighttext);
  if (cdfs == CDF_OK) {
    printf(
      "CDF data information for '%s' version %d.%d. Copyright information: %s\n",
      fn,
      version,
      release,
      copyrighttext);
    return true;
  } else {
    fprintf(
      stderr,
      "CDF getting document information failed with code: %d\n",
      cdfs);
  }

  return false;
}

bool display_document_attributes(CDFid id, long num) {
  CDFstatus cdfs;
  long i, j, attrscope, maxentry, entrytype, numelements;
  char attrname[CDF_ATTR_NAME_LEN256 + 1];
  char* buffer = NULL;
  size_t size;

  for (i = 0; i < num; i++) {
    cdfs = CDFattrInquire(id, i, attrname, &attrscope, &maxentry);
    if (cdfs == CDF_OK) {
      for (j = 0; j <= maxentry; j++) {
        cdfs = CDFattrEntryInquire(id, i, j, &entrytype, &numelements);
        if (cdfs == CDF_OK) {
          if (entrytype == CDF_CHAR) {
            size = (size_t)numelements + 1;
            buffer = (char*)malloc(size);
            if (buffer) {
              cdfs = CDFattrGet(id, i, j, (void*)buffer);
              buffer[numelements] = '\0';
              if (cdfs == CDF_OK) {
                printf("%s: %s\n", attrname, buffer);
              }
              free(buffer);
            }
          }
        }
      }
    } else {
      fprintf(
        stderr,
        "CDF attribute inquire failed with code: %d\n",
        cdfs);
    }
  }

  return true;
}

bool display_variable_information(CDFid id, const char* vn) {
  CDFstatus cdfs;
  long varnum;
  long vartype;
  long numelements, recvary;
  long dimvarys[CDF_MAX_DIMS];
  char varname[CDF_VAR_NAME_LEN256 + 1];
  char cdfst[CDF_STATUSTEXT_LEN + 1];

  varnum = CDFgetVarNum(id, vn);

  if (varnum >= CDF_OK) {
    cdfs = CDFvarInquire(
      id,
      varnum,
      varname,
      &vartype,
      &numelements,
      &recvary,
      dimvarys);
    if (cdfs == CDF_OK) {
    } else {
      CDFerror(cdfs, cdfst);
      fprintf(
        stderr,
        "CDF variable inquire for %s failed: %s (%d)\n",
        vn,
        cdfst,
        cdfs);
    }
  }

  return true;
}

bool display_variable_values(CDFid id, const char* vn) {
  CDFstatus cdfs;
  long varnum, attrnum, datatype, numelements;
  char cdfst[CDF_STATUSTEXT_LEN + 1];

  varnum = CDFgetVarNum(id, vn);
  if (varnum >= CDF_OK) {
    attrnum = CDFgetAttrNum(id, PARSE_CDF_FIELD_NAME);
    if (attrnum >= CDF_OK) {
      cdfs = CDFinquireAttrzEntry(
        id,
        attrnum,
        varnum,
        &datatype,
        &numelements);
      if (cdfs == CDF_OK) {

      }
    }
  }

  return true;
}
