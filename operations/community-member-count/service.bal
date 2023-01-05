import ballerina/http;
import wso2communitymembercounts.net;

# A service representing a network-accessible API
# bound to port `9090`.


configurable string INVITE_CODE=?;

final http:Client stackexchangeClient = check new ("https://api.stackexchange.com/2.3/collectives");
final http:Client discordClient = check new ("https://discord.com/api/v9/invites");
final http:Client githubClient = check new ("https://api.github.com");

service / on new http:Listener(9090) {

    # A service to get the community counts for Collectives, Discord an Github of wso2
    # + return - Community member counts
    resource function get landingPageCommunityCounts() returns http:Ok|http:Unauthorized|http:InternalServerError {
        return net:respond(getCountsForLandingPage());
    }
}

# Get comunity counts for discord, collectives and github
# + return - counts for landing page
isolated function getCountsForLandingPage() returns json|error {
    json|error collectiveResponse = getCollectivesMemberCount();
    json|error discordResponse = getDiscordMemberCount();
    json|error githubResponse = getGitHubMemberCount();

    if (collectiveResponse is json && discordResponse is json && githubResponse is json) {
        json response = {"discord_member_count": discordResponse, "collectives_member_count": collectiveResponse, "github_member_count": githubResponse};
        return response;
    }
    else {
        if (collectiveResponse is error) {
            return error net:customErr("Get collectives member count function", errorObject = collectiveResponse, externalMsg = "Error in fetching collectives member count", code = 500);

        } else if (discordResponse is error) {
            return error net:customErr("Get discord member count function", errorObject = discordResponse, externalMsg = "Error in fetching discord member count", code = 500);

        } else if (githubResponse is error) {
            return error net:customErr("Get github member count function", errorObject = githubResponse, externalMsg = "Error in fetching github member count", code = 500);

        }
    }

}

# Get Collectives member count
# + return - Return collective member count or error
isolated function getCollectivesMemberCount() returns json|error {
    string url = string `/wso2/users?order=desc&sort=reputation&site=stackoverflow&filter=total`;
    json response = check stackexchangeClient->get(url);
    return response.total;
    
}

# Get Discord member count
# + return - Return Discord member count or error
isolated function getDiscordMemberCount() returns json|error {
    string url = string `/${INVITE_CODE}?with_counts=true`;
    json response = check discordClient->get(url);
    json discordMembercount = check response.approximate_member_count;
    return discordMembercount;
    
}

# Get Github member count
# + return - Return Github member count or error
isolated function getGitHubMemberCount() returns json|error {
    int page = 1;
    string url = string `/orgs/wso2/members?page=${page}`;
    // remove if and error and add check only
    json[] response = check githubClient->get(url);
    
        int githubMemberCount = response.length();
        while (response != []) {
            page = page + 1;
            url = string `/orgs/wso2/members?page=${page}`;
            response = check githubClient->get(url);
            githubMemberCount = githubMemberCount + response.length();
        }
        return githubMemberCount.toJson();
}
