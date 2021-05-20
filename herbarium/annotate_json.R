setwd("D:/apm/google vision/sdr-datasets/herbarium")
library(tidyverse)
library(jsonlite)
library(magrittr)

#testset in JSON format
data = fromJSON("data/testset_ufix.json")

#darwin core (DwC) data for specimens published to GBIF
#get file from https://doi.org/10.5281/zenodo.3697797
dwc = read_csv("data/Data and Links excl extensions.csv",
               col_types = cols(.default = "c"))

#dwc terms of potential interest
prop = read_tsv("data/properties.txt")

#dwc terms to connect to entities
location = c("locality","county","country","verbatimLocality","stateProvince","higherGeography","municipality")
date = c("year","verbatimEventDate")
taxon = c("genus","specificEpithet","scientificName","infraspecificEpithet","scientificNameAuthorship")
person= c("recordedBy","identifiedBy")
barcode = c("catalogNumber","otherCatalogNumbers")
typestatus = c("typeStatus")


#annotate gold standard lines with matched DwC terms and with the 6 basic categories
data2=data
for (i in 1:length(data)) {
  src = data[[i]]$goldstandard
  src$note = ""
  src$location = ""
  src$date = ""
  src$taxon = ""
  src$person = ""
  src$barcode = ""
  src$typestatus = ""
  src$goldraw = tolower(gsub("[[:punct:]]",
                             "",
                             src$gold))
  subdwc = dwc %>%
    filter(catalogNumber==names(data)[i]) %>%
    select(all_of(prop$dwcterm))
  for (j in 1:dim(prop)[1]) {
    dwc_data = tolower(pull(subdwc[,j]))
    dwc_data = gsub("[[:punct:]]",
                    "",
                    dwc_data)
    if (!is.na(dwc_data)) {
      if (nchar(dwc_data)>1) {
        resu = agrep(dwc_data,src$goldraw)
        for (k in 1:length(resu)) {
          src$note[resu[k]] = paste(src$note[resu[k]],
                                    prop$dwcterm[j],
                                    sep="|")
          if (prop$dwcterm[j]%in%location) {
            src$location[resu[k]] = paste(src$location[resu[k]],
                                          pull(subdwc[,j]),
                                          sep="|")
          }
          if (prop$dwcterm[j]%in%taxon) {
            src$taxon[resu[k]] = paste(src$taxon[resu[k]],
                                       pull(subdwc[,j]),
                                       sep="|")
          }
          if (prop$dwcterm[j]%in%person) {
            src$person[resu[k]] = paste(src$person[resu[k]],
                                        pull(subdwc[,j]),
                                        sep="|")
          }
          if (prop$dwcterm[j]%in%barcode) {
            src$barcode[resu[k]] = paste(src$barcode[resu[k]],
                                         pull(subdwc[,j]),
                                         sep="|")
          }
          if (prop$dwcterm[j]%in%date) {
            src$date[resu[k]] = paste(src$date[resu[k]],
                                      pull(subdwc[,j]),
                                      sep="|")
          }
          if (prop$dwcterm[j]%in%typestatus) {
            src$typestatus[resu[k]] = paste(src$typestatus[resu[k]],
                                            pull(subdwc[,j]),
                                            sep="|")
          }
        }
      }
    }
  }
  src %<>% select(-goldraw)
  src$note = sub("|",
                 "",
                 src$note,
                 fixed=T)
  src$location = sub("|",
                     "",
                     src$location,
                     fixed=T)
  src$taxon = sub("|",
                  "",
                  src$taxon,
                  fixed=T)
  src$date = sub("|",
                 "",
                 src$date,
                 fixed=T)
  src$typestatus = sub("|",
                       "",
                       src$typestatus,
                       fixed=T)
  src$barcode = sub("|",
                    "",
                    src$barcode,
                    fixed=T)
  src$person = sub("|",
                   "",
                   src$person,
                   fixed=T)
  data2[[i]]$goldstandard = src
}

notesCount <- function(data,all=F) {
  #find all combination of dwc terms connected to a gold standard line
  notes = count(data[[1]]$goldstandard,
                   note)
  for (i in 2:length(data)) {
    notes = rbind(notes,
                  count(data[[i]]$goldstandard,
                        note))
  }
  if (all==T) {
    #all notes
    return(notes)
  } else {
    #only unique DwC term combinations
    return(count(notes,
                 note))
  }
}

selNotesCount <- function(data) {
  #calculate annotated entities per specimen
  for (i in 1:length(data)) {
    stat = data[[i]]$goldstandard %>%
      summarise(location = sum(!is.na(location)),
                taxon = sum(!is.na(taxon)),
                person = sum(!is.na(person)),
                date = sum(!is.na(date)),
                barcode = sum(!is.na(barcode)),
                typestatus = sum(!is.na(typestatus)))
    if (i!=1) {
      stat_summ = rbind(stat_summ,stat)
    } else {
      stat_summ = stat
    }
  }
  stat_summ$barcode = names(data2)
  return(stat_summ)
}

stats = selNotesCount(data2)

allnotes2 = notesCount(data2)
allnotes2all = notesCount(data2,all=T)

#function to quickly note DwC terms usage
# checkprop = allnotes2 %>%
#   separate_rows(note,sep="\\|") %>%
#   count(note)

#export results back to json
write_json(data2,
           "annotated-properties-v3.json",
           pretty=T)
