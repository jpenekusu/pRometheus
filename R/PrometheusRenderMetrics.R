######################################################################
#' Output for Prometheus to parse
#'
#' Generally call this as a /metrics end point in plumber
#'
#' @importFrom R6 R6Class
#' @export
PrometheusRenderMetrics <- R6Class(
  "PrometheusRenderMetrics",
  public = list(
    #' Initializing PrometheusRenderMetrics
    #'
    #' @return instance of PrometheusRenderMetrics
    initialize = function() {},

    #' Render text in the Prometheus format
    #'
    #' @param metrics list of MetricFamilySample
    #' @return string
    #' @examples
    #' registry <<- CollectorRegistry$new()
    #' renderer <- PrometheusRenderMetrics$new()
    #' out <- renderer$render(registry$getMetricFamilySamples())
    render = function(metrics) {
      output <- ""

      for (metric in metrics) {
        help <-
          paste("# HELP", metric$getName(), metric$getHelp(), sep = " ")
        type <-
          paste("# TYPE", metric$getName(), metric$getType(), sep = " ")

        output <- paste(output, help, type, sep = "\n")

        for (sample in metric$getSamples()) {
          sampleOutput <- private$renderSample(sample)
          output <- paste(output, sampleOutput, sep = "\n")
        }

        output <- paste0(output, "\n")
      }

      return(paste0(output, "\n"))
    }
  ),
  private = list(
    renderSample = function(sample) {
      label_output <- ""
      if (sample$hasLabelNames()) {
        count <- length(sample$getLabelNames())
        if (count == 1) {
          label_output <-
            paste0(sample$getLabelNames()[1],
                   '="',
                   sample$getLabelValues()[1],
                   '"')
        }
        else {
          for (i in 1:count) {
            single_label_output <-
              paste0(sample$getLabelNames()[i],
                     '="',
                     sample$getLabelValues()[i],
                     '"')
            label_output <-
              paste0(label_output, single_label_output)
            if (i < count) {
              label_output <- paste0(label_output, ",")
            }
          }
        }

        label_output <- paste0("{", label_output, "}")
      }

      return(paste0(sample$getName(), label_output, " ", sample$getValue()))
    }
  )
)
