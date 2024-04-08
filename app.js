const express = require('express');
const { exec } = require('child_process');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

app.get('/checker', (req, res) => {
    const { url, format } = req.query;
    if (!url) {
        return res.status(400).json({ message: "Missing 'url' query parameter." });
    }

    // Default to JSON if format is not specified or if it's not 'csv' or 'json'
    const responseFormat = ['csv', 'json'].includes(format) ? format : 'json';

    const scriptPath = path.join(__dirname, 'checker.sh');
    
    exec(`bash ${scriptPath} "${url}"`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).json({ message: `Script execution error: ${error.message}` });
        }

	stdout = stdout.trimEnd();
	
        // If the desired format is CSV
        if (responseFormat === 'csv') {
            res.setHeader('Content-Type', 'text/csv');
            res.charset = 'UTF-8';
            res.send(stdout.replace(/\s+/g, ","));
        } else {
            // Default to JSON response
            res.json({ message: stdout });
        }
    });
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
