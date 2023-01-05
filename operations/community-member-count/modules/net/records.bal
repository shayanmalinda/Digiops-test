import ballerina/http;

#CustomError details
type customErrDetail record {|
    http:STATUS_UNAUTHORIZED|http:STATUS_INTERNAL_SERVER_ERROR|http:STATUS_BAD_REQUEST code;
    string externalMsg;
    error errorObject;
|};

# CustomError
public type customErr error<customErrDetail>;