#' odds_plot - a function to create Odds Plots
#'
#' This has been created to generate odds plots on the back of results from a generalised linear model.
#'
#'
#' @param x The trained caret GLM logistic regression model
#' @param x_label The label name for the x_label
#' @param y_label The label name for the y_label
#' @param title Title for the Odds Plot
#' @param subtitle Subtitle for the Odds Plot
#' @param point_col Defaults to blues, but R colour codes can be passed
#' @param error_bar_colour the colour of the error bar
#' @param point_size the point size of the plot
#' @param error_bar_width the width of the displayed error bar
#' @param h_line_color the colour of the horizontal line
#' @import ggplot2 tibble
#' @importFrom magrittr %>%
#' @importFrom stats coef confint reorder
#' @return A list of the odds returned from logistic regression and a plot showing the odds
#' @export
#' @examples
#' #We will use the cancer dataset to build a GLM model to predict cancer status
#' #this will detail whether the patient has a benign or malignant
#'library(mlbench)
#'library(caret)
#'library(tibble)
#'library(ggplot2)
#'library(OddsPlotty)
#'library(e1071)
#'library(ggthemes)
#'
#'#Bring in the data
#'data("BreastCancer", package = "mlbench")
#'breast <- BreastCancer[complete.cases(BreastCancer), ]
#'breast <- breast[, -1]
#'head(breast, 10)
#Convert the class to a factor - Beningn (0) and Malignant (1)
#'breast$Class <- factor(breast$Class)
#'for(i in 1:9) {
#'breast[, i] <- as.numeric(as.character(breast[, i]))
#'}
#'
#'#Train GLM model
#'glm_model <- train(Class ~ ., data = breast, method = "glm", family = "binomial")
#'
#'#Visualise the data with OddsPlotty
#'plotty <- OddsPlotty::odds_plot(glm_model$finalModel,title = "Odds Plot")
#'plotty$odds_plot
#'
#'#Extract underlying odds ratios
#'plotty$odds_data



odds_plot <- function(x, x_label = "Variables" , y_label = "Odds Ratio",
                      title = NULL, subtitle = NULL, point_col='blue',
                      error_bar_colour = "black", point_size = 5,
                      error_bar_width = .3, h_line_color = "black"){

  # Set the variables to null

  OR <- NULL
  lower <- NULL
  upper <- NULL

  tmp <- data.frame(cbind(exp(coef(x)),
                          exp(confint(x))))
  odds <- tmp[-1,]
  names(odds) <-c('OR', 'lower', 'upper')

  odds$vars <- row.names(odds)
  odds_save <- as_tibble(odds)
  #Add ticks to lines
  ticks <- c(seq(.1, 1, by =.1), seq(0, 10, by =1), seq(10, 100, by =10))

  plot <- ggplot(odds, aes(y= OR, x = reorder(vars, OR))) +
    geom_point(aes(color=point_col), size = point_size, color = point_col) +
    geom_errorbar(aes(ymin=lower, ymax=upper),
                  width= error_bar_width, colour = error_bar_colour) +
    scale_y_log10(breaks=ticks, labels = ticks) +
    geom_hline(yintercept = 1, linetype=2, color = h_line_color) +
    coord_flip() +
    labs(title = title, subtitle = subtitle, x = x_label, y = y_label) +
    theme_bw() + theme(legend.position = "none")


  returns <- list("odds_data"=odds_save,
                  "odds_plot"=plot)

  return(returns)

}

