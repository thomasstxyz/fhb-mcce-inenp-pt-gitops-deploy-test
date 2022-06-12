const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient({region: "us-east-1"});
exports.handler = async (event) => {
let scanParameters = {
TableName: "todostest"
}
try {
const data = await docClient.scan(scanParameters).promise();
return {
"statusCode": 200,
"statusDescription": "200 OK",
"isBase64Encoded": false,
"headers": {
"Content-Type": "application/json"
},
"body": JSON.stringify(data)
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