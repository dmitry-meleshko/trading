/*

curl -X POST -H "x-api-key: XXX" -H "Content-Type: application/json" \
-d '{"ticker":"TSLA","start_date":"1544850000","end_date":"1545282000"}' \
https://YYY.execute-api.us-east-1.amazonaws.com/default/yquote


*/
const https = require("https");
const util = require("util");

exports.handler = (event, context, callback) => {
    var url = "https://finance.yahoo.com/quote/{TICKER}/history?" +
    "period1={START_DATE}&period2={END_DATE}&interval=1d&filter=history&frequency=1d";
    
    let body = '';
    let ticker = '';
    let start_date = '';
    let end_date = '';
    
    console.log("event: ", util.inspect(event, { showHidden: false, depth: null }))

    if (event.ticker) ticker = event.ticker;
    if (event.start_date) start_date = event.start_date;
    if (event.end_date) end_date = event.end_date;

    // params via body POST
    if (event.body != null && event.body !== undefined) {
        body = JSON.parse(event.body);
        if (body.ticker) ticker = body.ticker;
        if (body.start_date) start_date = body.start_date;
        if (body.end_date) end_date = body.end_date;
    }

    if (!(ticker && start_date && end_date)) {
        var e = new Error("Missing one of the required parameters")
        console.error(e);
        context.fail(e);
    }

    //console.log("Ticker: " + ticker);
    //console.log("Start date: " + start_date);
    //console.log("End date: " + end_date);

    url = url.replace("{TICKER}", ticker);
    url = url.replace("{START_DATE}", start_date);
    url = url.replace("{END_DATE}", end_date);


    const req =  https.get(url, res => {
            res.setEncoding("utf8");
            let body = "";    
    
            res.on("data", data => {
                    body += data;
            });
    
            res.on("end", () => {
                    //console.log(body);
                    var res = {
                        "statusCode": 200,
                        "headers": {
                            "ticker": ticker,
                            "start_date": start_date,
                            "end_date": end_date
                        },
                        //"body": JSON.stringify(body),
                        "body": body,
                        "isBase64Encoded": false
                    };
                    context.done(null, res);
            });
    
            res.on("error", (e) => {
                    console.error(e);
                    context.fail(e);
            });   
    }).on("error", (e) => {
            console.error(e);
            context.fail(e);
    });
}