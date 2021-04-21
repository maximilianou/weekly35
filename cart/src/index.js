const express = require('express')
const app = express()

app.get('/api/cart', (req, res) => {
  res.json({ message: `Cart API ${(new Date()).toISOString()}`})
})

app.listen( process.env.PORT, () => console.log(`Listening in http://localhost:${process.env.PORT}/api/cart`))
