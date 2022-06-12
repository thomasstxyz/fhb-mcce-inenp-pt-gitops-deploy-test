const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient({region: "us-east-1"});
exports.handler = async (event, context, callback) => {
let item = null;
if (event.requestContext) {
item = JSON.parse(event.body);
} else {
item = event;
}
let parameters = {
TableName: "todostest",
Key: {
"id": item.id
}
}
try {
const data = await docClient.delete(parameters).promise();
return {
"statusCode": 200,
"statusDescription": "200 OK",
"isBase64Encoded": false,
"headers": {
"Content-Type": "application/json"
},
"body": JSON.stringify({succeeded: true})
}
} catch(err) {
return {
"statusCode": 500,
"statusDescription": "500 Internal Server Error",
"isBase64Encoded": false,
"headers": {
"Content-Type": "application/json"
},
"body": JSON.stringify(err)
}
}
};