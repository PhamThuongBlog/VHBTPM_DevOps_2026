const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// ============================================
// In-memory database (giả lập)
// ============================================
let students = [
  { id: "SV001", name: "Nguyen Van A", age: 20, grade: "K20" },
  { id: "SV002", name: "Tran Thi B",   age: 21, grade: "K20" },
  { id: "SV003", name: "Le Van C",     age: 19, grade: "K21" },
];

// ============================================
// API Endpoints
// ============================================

// GET /api/students — Lấy danh sách sinh viên
app.get('/api/students', (req, res) => {
  res.json({ success: true, data: students, total: students.length });
});

// GET /api/students/:id — Lấy 1 sinh viên
app.get('/api/students/:id', (req, res) => {
  const student = students.find(s => s.id === req.params.id);
  if (!student) {
    return res.status(404).json({ success: false, message: 'Student not found' });
  }
  res.json({ success: true, data: student });
});

// POST /api/students — Thêm sinh viên mới
app.post('/api/students', (req, res) => {
  const { id, name, age, grade } = req.body;

  // ⚠️ Lỗi bảo mật #1: Không validate input (dễ bị XSS/SQL Injection)
  if (!id || !name) {
    return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  // ⚠️ Lỗi bảo mật #2: Không sanitize input
  const newStudent = { id, name, age: age || 0, grade: grade || '' };
  students.push(newStudent);

  res.status(201).json({ success: true, data: newStudent });
});

// PUT /api/students/:id — Cập nhật sinh viên
app.put('/api/students/:id', (req, res) => {
  const index = students.findIndex(s => s.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Student not found' });
  }

  // ⚠️ Lỗi bảo mật #3: Cho phép cập nhật tất cả fields (mass assignment)
  students[index] = { ...students[index], ...req.body };
  res.json({ success: true, data: students[index] });
});

// DELETE /api/students/:id — Xóa sinh viên
app.delete('/api/students/:id', (req, res) => {
  const index = students.findIndex(s => s.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Student not found' });
  }
  students.splice(index, 1);
  res.json({ success: true, message: 'Student deleted' });
});

// ⚠️ Lỗi bảo mật #4: Endpoint debug lộ thông tin
app.get('/api/debug', (req, res) => {
  res.json({
    environment: process.env,
    memory: process.memoryUsage(),
    uptime: process.uptime(),
  });
});

// GET /api/search?q= — Tìm kiếm (CÓ LỖI Reflected XSS)
app.get('/api/search', (req, res) => {
  const q = req.query.q || '';
  // ⚠️ Lỗi bảo mật #5: Phản hồi trực tiếp input không sanitize (Reflected XSS)
  const results = students.filter(s =>
    s.name.toLowerCase().includes(q.toLowerCase())
  );

  if (results.length === 0) {
    return res.send(`<p>Không tìm thấy sinh viên với từ khóa: <b>${q}</b></p>`);
  }

  res.json({ success: true, data: results, keyword: q });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Student API running at http://localhost:${PORT}`);
  console.log(`📋 Endpoints:`);
  console.log(`   GET    /api/students`);
  console.log(`   GET    /api/students/:id`);
  console.log(`   POST   /api/students`);
  console.log(`   PUT    /api/students/:id`);
  console.log(`   DELETE /api/students/:id`);
  console.log(`   GET    /api/search?q=`);
  console.log(`   GET    /api/debug ⚠️ (lộ thông tin)`);
});
