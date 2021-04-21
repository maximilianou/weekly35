const express = require('express')
const app = express()

app.get('/api/products', (req, res) => {
  res.json({ message: `Products API ${(new Date()).toISOString()}`})
})

app.listen( process.env.PORT, () => console.log(`Listening in http://localhost:${process.env.PORT}/api/products`))
