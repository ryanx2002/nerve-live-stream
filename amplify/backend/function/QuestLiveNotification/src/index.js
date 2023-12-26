/* Amplify Params - DO NOT EDIT
	API_NERVELIVESTREAM_GRAPHQLAPIENDPOINTOUTPUT
	API_NERVELIVESTREAM_GRAPHQLAPIIDOUTPUT
	API_NERVELIVESTREAM_GRAPHQLAPIKEYOUTPUT
	AUTH_NERVELIVESTREAM_USERPOOLID
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const express = require("express");
const bodyParser = require("body-parser");
const awsServerlessExpressMiddleware = require("aws-serverless-express/middleware");
const AWS = require("aws-sdk");
const gql = require("graphql-tag");
const AWSAppSyncClient = require("aws-appsync").default;
require("es6-promise").polyfill();
require("isomorphic-fetch");

const app = express();
app.use(bodyParser.json());
app.use(awsServerlessExpressMiddleware.eventContext());

app.use(function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

const url = process.env.API_NERVELIVESTREAM_GRAPHQLAPIENDPOINTOUTPUT;
const region = process.env.REGION;

const credentials = AWS.config.credentials;

AWS.config.update({
  region,
  credentials: new AWS.Credentials(
    process.env.AWS_ACCESS_KEY_ID,
    process.env.AWS_SECRET_ACCESS_KEY,
    process.env.AWS_SESSION_TOKEN
  ),
});

const appsyncClient = new AWSAppSyncClient(
	{
	  url,
	  region,
	  auth: {
		type: "API_KEY",
		apiKey: "da2-4nghlyufivg3ldc4m27lzwhdce", // 替换成你的 API Key
	  },
	  disableOffline: true,
	},
	{
	  defaultOptions: {
		query: {
		  fetchPolicy: "network-only",
		  errorPolicy: "all",
		},
	  },
	}
  );

const queryUserProfile = /* GraphQL */ gql`
query MyQuery($id:ID!) {
  getUser(id:$id) {
        createdAt
        deviceToken
        email
        firstName
        id
        lastName
        phone
        profilePhoto
        updatedAt
        venmo
        isMaster
        isLive
    }
}
`;

const queryUserList = /* GraphQL */ gql`
query MyQuery {
  listUsers {
    items {
      createdAt
      deviceToken
      email
      firstName
      id
      lastName
      phone
      profilePhoto
      updatedAt
      venmo
      isMaster
      isLive
    }
  }
}
`;

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
	var message;
  for (var i = 0; i < event.Records.length; i++) {
    const record = event.Records[i];
    if (record.eventName === "MODIFY") {
      console.log(JSON.stringify(record));
      message = record.dynamodb.NewImage;
    }
  }
  const client = await appsyncClient.hydrated();
	const isMaster = message.isMaster.BOOL;
  const isLive = message.isLive.BOOL;
  if (isMaster && isLive) {
    /// 分发用户的信息
    const list = await client.query({
      query: queryUserList,
      variables: {},
    });
    console.log(`list:${JSON.stringify(list)}`);
    const listUsers = list.data.listUsers.items;
    console.log(`listUsers:${JSON.stringify(listUsers)}`);
    for(let i = 0; i < listUsers.length; i++) {
      let user = listUsers[i];
      let deviceToken = user.deviceToken;
      if (user.isMaster === false) {
        sendMessage(message, deviceToken)
      }
      console.log(`user: ${user.phone}`);
    }
  }
};

/// 发送消息
async function sendMessage(message, deviceToken) {
	let messageRequest = CreateMessageRequest(
		deviceToken,
		message,
		"Quest"
	);
	const sendMessagesParams = {
		ApplicationId: "4159edc2528648868ec7dfdfa8ef8439", // Find it in Pinpoint->All projects
		MessageRequest: messageRequest,
	};

	console.log(`111==${JSON.stringify(sendMessagesParams)}`);

	//Create a new Pinpoint object.
	let pinpoint = new AWS.Pinpoint();
	// Try to send the message.
	try {
    const response = await pinpoint.sendMessages(sendMessagesParams).promise();
    console.log('Push notification sent:', response);
    return {
      statusCode: 200,
      body: JSON.stringify(response),
    };
  } catch (err) {
    console.info('Error sending push notification:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Push notification failed' }),
    };
  }
}

function CreateMessageRequest(deviceToken, message, fromUserName, aboutUserProfileModel, aboutUserContentModel) {
  let firstName = message.firstName.S;

  return {
    Addresses: {
      [deviceToken]: {
        ChannelType: "APNS", // APNS  APNS_SANDBOX
      },
    },
    MessageConfiguration: {
      APNSMessage: {
        Action: "OPEN_APP",
        Body: `${firstName} is live! You can request anything`,
        SilentPush: false,
        Title: fromUserName,
        TimeToLive: 30,
        Priority: "high",
      },
    },
  };
}
