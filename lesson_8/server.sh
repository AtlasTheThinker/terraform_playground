#!/bin/bash
yum update -y
yum install -y httpd
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Hello Page</title>
    <style>
        body {
            background-color: #f0f0f0;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <h1>Gamarjoba, $(hostname -I)</h1>
</body>
</html>
EOF
systemctl start httpd
systemctl enable httpd