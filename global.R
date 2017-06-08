
if (!require("pacman")) install.packages("pacman") # package managment tool
pacman::p_install_gh('tbadams45/wrviz')
pacman::p_load(
  shiny,
  shinyBS,
  shinydashboard,
  shinythemes,
  shinyjs,
  wrviz,
  tidyr,
  dplyr,
  ggplot2)

