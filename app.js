const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.get('/checker', (req, res) => {
    const { url } = req.query; // Extract 'url' from query parameters
    if (!url) {
        return res.status(400).json({ message: "Missing 'url' query parameter" });
    }

    const scriptPath = path.join(__dirname, 'checker.sh'); // Adjust the path to your script as necessary

    exec(`bash ${scriptPath} "${url}"`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            return res.status(500).json({ message: `Script execution error: ${error.message}` });
        }
        res.json({ message: stdout });
    });
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
