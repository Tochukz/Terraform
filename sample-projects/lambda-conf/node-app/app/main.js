'use strict';

exports.handler = function (event, context, callback) {
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: "Hello LilaLove!",
    };
    callback(null, response);
};