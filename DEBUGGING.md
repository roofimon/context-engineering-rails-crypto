# Debugging ApexCharts Display Issue

## Step-by-Step Debugging Guide

### 1. Check Browser Console
Open your browser's Developer Tools (F12) and check the Console tab. Look for:
- ✅ Success messages (charts rendering)
- ❌ Error messages (what's failing)
- 🔍 Debug messages (status updates)

### 2. Check Network Tab
In the Network tab, verify:
- Is `apexcharts.esm.js` loading successfully? (Status 200)
- Are there any failed requests?

### 3. Check Importmap
Verify the importmap is configured correctly:
```bash
# Check the importmap file
cat config/importmap.rb
```

### 4. Check Application.js
Verify ApexCharts is imported:
```bash
# Check the application.js file
cat app/javascript/application.js
```

### 5. Common Issues and Solutions

#### Issue: "ApexCharts is not loaded"
**Possible causes:**
- Importmap not loading the CDN URL
- CDN URL is incorrect
- JavaScript module not being processed

**Solutions:**
1. Check if the importmap pin is correct
2. Verify the CDN URL is accessible
3. Try using a different CDN or version

#### Issue: "Chart element not found"
**Possible causes:**
- Turbo Frame not loading the content
- Element ID mismatch
- Script running before DOM is ready

**Solutions:**
1. Check if the turbo_frame_tag is correct
2. Verify element IDs match
3. Check Turbo event listeners

#### Issue: "Charts render but are blank"
**Possible causes:**
- Data not in correct format
- Chart options incorrect
- CSS/styling issues

**Solutions:**
1. Check console for data format
2. Verify chart options
3. Check element dimensions

### 6. Manual Testing

Open browser console and run:
```javascript
// Check if ApexCharts is available
console.log('ApexCharts:', window.ApexCharts);
console.log('Type:', typeof window.ApexCharts);

// Check if chart elements exist
document.querySelectorAll('[id^="chart-"]').forEach(el => {
  console.log('Chart element:', el.id, el);
});

// Try to manually create a chart
const testElement = document.getElementById('chart-BTC');
if (testElement && window.ApexCharts) {
  const testChart = new window.ApexCharts(testElement, {
    series: [{ data: [10, 20, 30] }],
    chart: { type: 'line', height: 200 }
  });
  testChart.render();
}
```

### 7. Check Server Logs
Look for any errors in your Rails server logs when loading the page.

### 8. Verify Importmap is Working
Check if the importmap is being served correctly:
```bash
# In browser, visit:
http://localhost:3000/assets/application.js
# Should see imports including apexcharts
```

## Quick Fixes to Try

1. **Restart Rails server** - Sometimes changes need a restart
2. **Clear browser cache** - Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. **Check CSP headers** - Content Security Policy might be blocking CDN
4. **Try different CDN version** - The ESM version might have issues

## Next Steps
Based on console output, we can:
1. Fix the importmap configuration
2. Adjust the import statement
3. Use a different loading method
4. Create a Stimulus controller for better integration

