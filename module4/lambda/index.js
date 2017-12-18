// Load the SDK for JavaScript
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'us-west-2'});
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = (event, context, callback) => {
    // TODO implement
        var params = {
            ExpressionAttributeValues: {
                ':p': {S: event.body},
            },
            KeyConditionExpression: 'ProjectEnvironment = :p',
            ProjectionExpression: 'ProjectEnvironment, Subnets, Environment, VPCIPAddressRange',
            TableName: 'ddt-datasource'
        };

    ddb.query(params, function(err, data) {
        if (err) {
            console.log("Error", err);
            callback(err);
        } else {
            var response = {
                "statusCode" : 200,
                "headers": {},
                "body": JSON.stringify(data.Items),
                "isBase64Encoded": false
            };
            callback(null, response);
        }
    });
};