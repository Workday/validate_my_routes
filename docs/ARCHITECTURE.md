# ValidateMyRoutes Architecture

## API request validation flow

![Request validation flow diagram](./images/request_validation_flow.png)

## Rule validation

For **all parameters validation** `VALUE` is a Sinatra `params`
For **single parameter validation** instead of `VALUE` there will be 2 parameters:
  `PARAM_VALUE, PARAM_NAME`

![Request validation flow diagram](./images/rule_validation.png)
