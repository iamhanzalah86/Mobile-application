const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// In-memory storage (resets when server restarts)
let activities = [];

// ============= ROUTES =============

// 1. CREATE ACTIVITY (POST)
app.post('/api/activities', (req, res) => {
  try {
    const { id, latitude, longitude, imagePath, timestamp, address } = req.body;

    // Validation
    if (!id || latitude === undefined || longitude === undefined || !imagePath || !timestamp) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Check if already exists
    const exists = activities.find(a => a.id === id);
    if (exists) {
      return res.status(400).json({ error: 'Activity already exists' });
    }

    // Create new activity
    const newActivity = {
      id,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      imagePath,
      timestamp: new Date(timestamp),
      address: address || 'Unknown location',
      synced: true,
      createdAt: new Date()
    };

    activities.push(newActivity);

    console.log(`✓ Activity created: ${id}`);
    res.status(201).json({
      success: true,
      message: 'Activity created successfully',
      data: newActivity
    });
  } catch (error) {
    console.error('Error creating activity:', error);
    res.status(500).json({ error: error.message });
  }
});

// 2. GET ALL ACTIVITIES (GET)
app.get('/api/activities', (req, res) => {
  try {
    const { search, limit = 50, skip = 0 } = req.query;

    let filtered = activities;

    // Search by address
    if (search) {
      filtered = activities.filter(a =>
        a.address.toLowerCase().includes(search.toLowerCase()) ||
        a.id.toLowerCase().includes(search.toLowerCase())
      );
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    // Pagination
    const paginated = filtered.slice(parseInt(skip), parseInt(skip) + parseInt(limit));

    res.json({
      success: true,
      data: paginated,
      pagination: {
        total: filtered.length,
        limit: parseInt(limit),
        skip: parseInt(skip),
        pages: Math.ceil(filtered.length / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error fetching activities:', error);
    res.status(500).json({ error: error.message });
  }
});

// 3. GET SINGLE ACTIVITY (GET)
app.get('/api/activities/:id', (req, res) => {
  try {
    const activity = activities.find(a => a.id === req.params.id);

    if (!activity) {
      return res.status(404).json({ error: 'Activity not found' });
    }

    res.json({
      success: true,
      data: activity
    });
  } catch (error) {
    console.error('Error fetching activity:', error);
    res.status(500).json({ error: error.message });
  }
});

// 4. UPDATE ACTIVITY (PUT)
app.put('/api/activities/:id', (req, res) => {
  try {
    const activity = activities.find(a => a.id === req.params.id);

    if (!activity) {
      return res.status(404).json({ error: 'Activity not found' });
    }

    // Update fields
    activity.latitude = req.body.latitude || activity.latitude;
    activity.longitude = req.body.longitude || activity.longitude;
    activity.imagePath = req.body.imagePath || activity.imagePath;
    activity.address = req.body.address || activity.address;
    activity.timestamp = req.body.timestamp || activity.timestamp;
    activity.synced = req.body.synced !== undefined ? req.body.synced : activity.synced;
    activity.updatedAt = new Date();

    console.log(`✓ Activity updated: ${req.params.id}`);
    res.json({
      success: true,
      message: 'Activity updated successfully',
      data: activity
    });
  } catch (error) {
    console.error('Error updating activity:', error);
    res.status(500).json({ error: error.message });
  }
});

// 5. DELETE ACTIVITY (DELETE)
app.delete('/api/activities/:id', (req, res) => {
  try {
    const index = activities.findIndex(a => a.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ error: 'Activity not found' });
    }

    const deleted = activities.splice(index, 1);

    console.log(`✓ Activity deleted: ${req.params.id}`);
    res.json({
      success: true,
      message: 'Activity deleted successfully',
      data: deleted[0]
    });
  } catch (error) {
    console.error('Error deleting activity:', error);
    res.status(500).json({ error: error.message });
  }
});

// 6. SEARCH ACTIVITIES (GET)
app.get('/api/activities/search/:query', (req, res) => {
  try {
    const results = activities.filter(a =>
      a.address.toLowerCase().includes(req.params.query.toLowerCase())
    );

    res.json({
      success: true,
      data: results,
      count: results.length
    });
  } catch (error) {
    console.error('Error searching activities:', error);
    res.status(500).json({ error: error.message });
  }
});

// 7. GET RECENT ACTIVITIES (GET)
app.get('/api/activities/recent/:limit', (req, res) => {
  try {
    const limit = parseInt(req.params.limit) || 5;
    const recent = activities
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
      .slice(0, limit);

    res.json({
      success: true,
      data: recent,
      count: recent.length
    });
  } catch (error) {
    console.error('Error fetching recent activities:', error);
    res.status(500).json({ error: error.message });
  }
});

// 8. HEALTH CHECK (GET)
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date(),
    totalActivities: activities.length
  });
});

// ============= ERROR HANDLER =============
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: err.message });
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ============= SERVER =============
const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔════════════════════════════════════════╗
║   SmartTracker Backend Server          ║
║   ✓ Running on http://localhost:${PORT}    ║
║   ✓ CORS Enabled                       ║
║   ✓ Ready to receive requests          ║
╚════════════════════════════════════════╝
  `);
});
