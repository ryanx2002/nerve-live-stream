import Foundation
import AWSCognitoIdentityProvider

// Cognito constants
let awsCognitoUserPoolsSignInProviderKey = "UserPool"

let cognitoIdentityUserPoolRegion = AWSRegionType.USEast1 //  <- REPLACE ME!
let cognitoIdentityUserPoolId = "us-east-1_meRyGtTCd"
let cognitoIdentityUserPoolAppClientId = "64tkrejscnmpmsnppdbk4q9452"
let cognitoIdentityUserPoolAppClientSecret = "REPLACEME"
let cognitoIdentityPoolId = "us-east-1:d3c35d6f-b2d7-490e-9f82-6058e418b32d"

// App constants
let appName = "aws-kvs-webrtc-ios-client"
let appVersion = "1.0.0"

// KinesisVideo constants
let awsKinesisVideoKey = "kinesisvideo"
let videoProtocols =  ["WSS", "HTTPS"]

// Connection constants
let connectAsMasterKey = "connect-as-master"
let connectAsViewerKey = "connect-as-viewer"

let masterRole = "MASTER"
let viewerRole = "VIEWER"
let connectAsViewClientId = "ConsumerViewer"

let userAgentHeader = "User-Agent"

// AWSv4 signer constants
let signerAlgorithm = "AWS4-HMAC-SHA256"
let awsRequestTypeKey = "aws4_request"
let xAmzAlgorithm = "X-Amz-Algorithm"
let xAmzCredential = "X-Amz-Credential"
let xAmzDate = "X-Amz-Date"
let xAmzExpiresKey = "X-Amz-Expires"
let xAmzExpiresValue = "299"
let xAmzSecurityToken = "X-Amz-Security-Token"
let xAmzSignature = "X-Amz-Signature"
let xAmzSignedHeaders = "X-Amz-SignedHeaders"
let newlineDelimiter = "\n"
let slashDelimiter = "/"
let colonDelimiter = ":"
let plusDelimiter = "+"
let equalsDelimiter = "="
let ampersandDelimiter = "&"
let restMethod = "GET"
let utcDateFormatter = "yyyyMMdd'T'HHmmss'Z'"
let utcTimezone = "UTC"

let hostKey = "host"
let wssKey = "wss"

let plusEncoding = "%2B"
let equalsEncoding = "%3D"

