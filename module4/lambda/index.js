// Load the SDK for JavaScript
var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'us-west-2'});
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = (event, context, callback) => {
    // TODO implement
        var params = {
            ExpressionAttributeValues: {
                ':p': {S: event.headers["querytext"]},
            },
            KeyConditionExpression: 'ProjectEnvironment = :p',
            TableName: 'ddt-datasource'
        };

    ddb.query(params, function(err, data) {
        if (err) {
            console.log("Error", err);
            callback(err);
        } else {
            var responseBody = '{';
            data.Items.forEach(function(item) {
            responseBody += '"ProjectEnvironment":"' + item.ProjectEnvironment.S
            + '","asg_instance_size":"' + item.asg_instance_size.S
            + '","asg_min_size":"' + item.asg_min_size.S
            + '","asg_max_size":"' + item.asg_max_size.S
            + '","environment":"' + item.environment.S
            + '","billing_code":"' + item.billing_code.S
            + '","project_code":"' + item.project_code.S
            + '","network_lead":"' + item.network_lead.S
            + '","application_lead":"' + item.application_lead.S
            + '","rds_engine":"' + item.rds_engine.S
            + '","rds_version":"' + item.rds_version.S
            + '","rds_instance_size":"' + item.rds_instance_size.S
            + '","rds_multi_az":"' + item.rds_multi_az.S
            + '","rds_storage_size":"' + item.rds_storage_size.S
            + '","rds_db_name":"' + item.rds_db_name.S
            + '","vpc_subnet_count":"' + item.vpc_subnet_count.S
            + '","vpc_cidr_range":"' + item.vpc_cidr_range.S
            + '"}';
        });
            var response = {
                "statusCode" : 200,
                "headers": {},
                "body": responseBody,
                "isBase64Encoded": false
            };
            callback(null, response);
        }
    });
};