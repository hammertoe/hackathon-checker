// netlify/functions/bash-wrapper.js
const { exec } = require('child_process');
const path = require('path');

exports.handler = async (event, context) => {
  return new Promise((resolve, reject) => {
      // Adjust the path to your script
      const scriptPath = path.join(__dirname, '..', '..', 'checker.sh');
      const { url } = event.queryStringParameters;
      
      exec(`bash ${scriptPath} ${url}`, (error, stdout, stderr) => {
	  if (error) {
              console.error(`exec error: ${error}`);
              return reject({
		  statusCode: 500,
		  body: JSON.stringify({ message: `Script execution error: ${error.message}` }),
              });
	  }
	  resolve({
              statusCode: 200,
              body: JSON.stringify({ message: stdout }),
	  });
      });
  });
};
