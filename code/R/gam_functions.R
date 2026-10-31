calculate_model_results <- function(data) {

  data %>%
    mutate(
      covered = lower <= truth & upper >= truth,
      mag_truth = abs(truth),
      covered = as.numeric(covered)
    )

}
predict_covered <- function(data, x_values) {

  fit <- gam(covered ~ s(truth), data = data, family = binomial)
  y_values <- predict(fit, data.frame(truth = x_values, group = 101), type = "response")
  data.frame(x = x_values, y = y_values)

}
