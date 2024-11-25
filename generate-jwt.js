const jwt = require('jsonwebtoken');
const fs = require('fs');

// Cargar la clave privada desde el archivo generado en el paso del action
const privateKey = fs.readFileSync('private-key.pem');

// Crear el JWT
const uwu = jwt.sign(
  {
    // Este token expira en 10 minutos
    exp: Math.floor(Date.now() / 1000) + 600,
    iss: process.env.GITHUB_APP_ID, // Usar el ID de la GitHub App desde los secretos
  },
  privateKey,
  { algorithm: 'RS256' }
);
fs.writeFileSync('token.txt', uwu);
