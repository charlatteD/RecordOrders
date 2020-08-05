#load libraries
library(shiny)
library(shinydashboard)
library(googledrive)
library(googlesheets4)
library("DT")

#get your token to access google drive
gs4_auth_configure(api_key = "AIzaSyAWqUrQnVhejsGQMJY4-MtsZkI3ZCSZ27M")

#google_app <- gs_auth(key = "350761824600-3lerqmu2cebe9pd12h4k11e6d955cge9.apps.googleusercontent.com",
#                                     secret = "a-6yfhPVQeuyPxf3VJ7XZwWw")

drive_auth()

gs4_auth(scope = "https://www.googleapis.com/auth/drive")

initial_sheet <- data.frame(Restaurant = 0, Rice_Noodle = 0,  Egg_Noodle = 0)

(ss <- gs4_create("order", sheets = initial_sheet))


