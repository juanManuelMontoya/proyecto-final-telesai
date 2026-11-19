// Sitio institucional TELESAI - Proyecto Final Administración de Infraestructura de TI
// Express + MySQL (base de datos creada en Dokploy)
const express = require('express');
const path = require('path');
const os = require('os');
const mysql = require('mysql2/promise');

const app = express();
const port = process.env.PORT || 3000;
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5
});

const SERVICIOS = [
  ['Aseo y desinfección', 'Limpieza profunda y desinfección de oficinas, locales y áreas comunes con protocolos documentados.', 'Comercial y corporativo'],
  ['Aseo hospitalario', 'Limpieza y desinfección de áreas clínicas siguiendo protocolos de bioseguridad.', 'Hospitalario'],
  ['Mantenimiento locativo', 'Reparaciones menores, pintura y mantenimiento preventivo de instalaciones.', 'Todos los sectores'],
  ['Aseo post-obra', 'Limpieza final de proyectos de construcción antes de su entrega.', 'Construcción'],
  ['Sellado y brillado de pisos', 'Tratamiento, sellado y brillado de pisos en diferentes materiales.', 'Comercial e industrial'],
  ['Jardinería', 'Mantenimiento de zonas verdes, poda y ornamentación.', 'Corporativo y residencial'],
  ['Servicio de cafetería', 'Personal capacitado para atención de cafetería en empresas.', 'Corporativo'],
  ['Mantenimiento de piscinas', 'Limpieza, tratamiento de agua y control químico de piscinas.', 'Residencial y recreativo']
];

async function initDB() {
  for (let intento = 1; intento <= 15; intento++) {
    try {
      await pool.query(`CREATE TABLE IF NOT EXISTS servicios (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NOT NULL,
        sector VARCHAR(100) NOT NULL)`);
      await pool.query(`CREATE TABLE IF NOT EXISTS solicitudes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        empresa VARCHAR(100),
        telefono VARCHAR(30),
        servicio VARCHAR(100),
        mensaje TEXT,
        fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP)`);
      const [[{ total }]] = await pool.query('SELECT COUNT(*) AS total FROM servicios');
      if (total === 0) {
        await pool.query('INSERT INTO servicios (nombre, descripcion, sector) VALUES ?', [SERVICIOS]);
      }
      console.log('Base de datos lista');
      return;
    } catch (err) {
      console.log(`Esperando MySQL (intento ${intento}): ${err.message}`);
      await new Promise(r => setTimeout(r, 4000));
    }
  }
}

app.get('/api/servicios', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, nombre, descripcion, sector FROM servicios ORDER BY id');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/solicitudes', async (req, res) => {
  const { nombre, empresa, telefono, servicio, mensaje } = req.body || {};
  if (!nombre || !mensaje) return res.status(400).json({ error: 'Nombre y mensaje son obligatorios' });
  try {
    const [r] = await pool.query(
      'INSERT INTO solicitudes (nombre, empresa, telefono, servicio, mensaje) VALUES (?, ?, ?, ?, ?)',
      [nombre, empresa, telefono, servicio, mensaje]);
    res.status(201).json({ ok: true, id: r.insertId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/solicitudes', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, nombre, empresa, servicio, fecha FROM solicitudes ORDER BY id DESC LIMIT 20');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', async (req, res) => {
  let db = 'desconectada', version = null;
  try {
    const [[r]] = await pool.query('SELECT VERSION() AS version');
    db = 'conectada'; version = r.version;
  } catch (e) { db = 'error: ' + e.message; }
  res.json({ estado: 'ok', servidor: os.hostname(), base_datos: db, mysql: version, db_host: process.env.DB_HOST, fecha: new Date().toISOString() });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Sitio TELESAI escuchando en el puerto ${port}`);
  initDB();
});
