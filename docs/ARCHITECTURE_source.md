# ValidateMyRoutes Architecture

## API request validation flow

```mermaid
sequenceDiagram
  participant client
  participant sinatra route
  participant sinatra conditions
  participant route
  participant validation rule(s)

  client->>sinatra route: request a resource
  activate sinatra route
  sinatra route->>sinatra conditions: validate parameters
  activate sinatra conditions
  loop Each path parameter from :validate_params
    sinatra conditions->>validation rule(s):validate single path parameter
    validation rule(s)-->>sinatra conditions:true/false/exception
  end
  loop Each query parameter from :validate_params
    sinatra conditions->>validation rule(s):validate single query parameter
    validation rule(s)-->>sinatra conditions:true/false/exception
  end
  sinatra conditions-->>sinatra route: true/false/exception
  deactivate sinatra conditions
  sinatra route->>sinatra conditions: validate all parameters
  activate sinatra conditions
  loop Each rule from :validate_all_params
    sinatra conditions->>validation rule(s):validate params
    validation rule(s)-->>sinatra conditions:true/false/exception
  end
  sinatra conditions-->>sinatra route: true/false/exception
  deactivate sinatra conditions
  sinatra route->>route: params
  activate route
  route-->>sinatra route: response
  deactivate route
  sinatra route-->>client: response
  deactivate sinatra route
```

## Rule validation

For **all parameters validation** `VALUE` is a Sinatra `params`
For **single parameter validation** instead of `VALUE` there will be 2 parameters:
  `PARAM_VALUE, PARAM_NAME`

```mermaid
sequenceDiagram
  participant caller
  participant validation flow control
  participant rule flow control
  participant rule.validate
  participant rule.failure_message
  participant rule.failure_code

  activate caller
  caller->>validation flow control: validate VALUE
  activate validation flow control
  validation flow control->>rule flow control:validate VALUE
  activate rule flow control
  rule flow control->>rule.validate: validate VALUE
  activate rule.validate
  rule.validate->>rule flow control: true/false or fail
  deactivate rule.validate
  alt true
    rule flow control->>validation flow control:true
    validation flow control->>caller: true
  else false or fail
    rule flow control->>rule.failure_message: get error message
    rule.failure_message->>rule flow control: message
    rule flow control->>rule.failure_code: get failure code
    rule.failure_code->>rule flow control: code
    rule flow control->>validation flow control:soft/hard fail
    validation flow control->>caller: false/fail
  end
  deactivate rule flow control
  deactivate validation flow control
  deactivate caller
```
