import ballerina/http;

# HTTP responces
public type Response http:Ok|http:Unauthorized|http:InternalServerError;

# Build HTTP Response based on the input
#
# + reply - Reply from the service
# + return - Return Value custom error or success message
public isolated function respond(anydata|error reply) returns Response {
    if reply is error {
        string message;
        if reply is customErr {
            customErrDetail detail = reply.detail();
            message = detail.externalMsg;
            if detail.code == http:STATUS_UNAUTHORIZED {
                http:Unauthorized e = {body: {message}};
                return e;
            }
        } else {
            message = "Unknown error, Please contact Internal Apps team";
        }
        http:InternalServerError e = {body: {message}};
        return e;
    } else {
        http:Ok ok = {body: reply};
        return ok;
    }
}

