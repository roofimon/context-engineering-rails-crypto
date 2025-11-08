import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('=== MARKET TREND CONTROLLER CONNECTED ===')
    // Clear any existing charts to prevent conflicts
    if (this.charts) {
      this.charts.forEach(chart => {
        if (chart && typeof chart.destroy === 'function') {
          chart.destroy()
        }
      })
    }
    this.charts = []
    this.initializeCharts()
  }

  disconnect() {
    // Clean up charts when controller disconnects
    if (this.charts) {
      this.charts.forEach(chart => {
        if (chart && typeof chart.destroy === 'function') {
          chart.destroy()
        }
      })
      this.charts = []
    }
  }

  initializeCharts() {
    // Get assets data from JSON script tag
    const scriptTag = document.querySelector('script[data-market-trend-assets]')
    if (!scriptTag) {
      console.error('Assets data script tag not found')
      return
    }

    // Parse assets data from JSON
    let assetsData
    try {
      assetsData = JSON.parse(scriptTag.textContent)
    } catch (error) {
      console.error('Failed to parse assets data:', error)
      return
    }

    console.log('Assets data loaded:', assetsData)

    // Wait for ApexCharts to be available
    this.waitForApexChartsAndCreate(assetsData)
  }

  waitForApexChartsAndCreate(assetsData) {
    if (window.ApexCharts && typeof window.ApexCharts === 'function') {
      console.log('✅ ApexCharts is available!')
      assetsData.forEach((asset) => {
        this.updateStatus(asset.symbol, 'ApexCharts ready, creating chart...')
      })

      setTimeout(() => {
        console.log('Starting to create charts...')
        this.createAllCharts(assetsData)
      }, 100)
    } else {
      console.log('⏳ ApexCharts not ready yet, waiting...')
      setTimeout(() => {
        this.waitForApexChartsAndCreate(assetsData)
      }, 100)
    }
  }

  createAllCharts(assetsData) {
    console.log('=== Starting chart creation ===')

    if (!window.ApexCharts) {
      console.error('❌ ApexCharts not available')
      return
    }

    assetsData.forEach((asset) => {
      console.log('=== Creating chart for ' + asset.symbol + ' ===')
      this.updateStatus(asset.symbol, 'Creating chart for ' + asset.symbol + '...')

      const elementId = 'chart-' + asset.symbol
      const chartElement = document.getElementById(elementId)

      if (!chartElement) {
        console.error('Element not found:', elementId)
        this.updateStatus(asset.symbol, 'ERROR: Element not found')
        return
      }

      this.updateStatus(asset.symbol, 'Element found, preparing data...')

      // Format data for area chart - extract close prices from candlestick data
      const formattedData = asset.dates.map((date, index) => {
        const candle = asset.candlestickData[index] // [open, high, low, close]
        const closePrice = candle[3] // Extract close price (4th element)
        return {
          x: date,
          y: closePrice
        }
      })

      console.log('Data prepared for ' + asset.symbol + ':', formattedData.length + ' data points')
      this.updateStatus(asset.symbol, 'Data ready (' + formattedData.length + ' data points)')

      // Create chart options for area chart
      const options = {
        series: [{
          name: asset.symbol,
          data: formattedData
        }],
        chart: {
          type: 'area',
          height: 250,
          toolbar: { show: false },
          zoom: { enabled: false }
        },
        dataLabels: {
          enabled: false
        },
        stroke: {
          curve: 'smooth',
          width: 2,
          colors: ['#3B82F6'] // Blue line
        },
        fill: {
          type: 'gradient',
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.7,
            opacityTo: 0.3,
            stops: [0, 100],
            colorStops: [
              {
                offset: 0,
                color: '#3B82F6',
                opacity: 0.7
              },
              {
                offset: 100,
                color: '#3B82F6',
                opacity: 0.3
              }
            ]
          }
        },
        xaxis: {
          type: 'category',
          labels: {
            show: false
          },
          axisBorder: {
            show: false
          },
          axisTicks: {
            show: false
          }
        },
        yaxis: {
          labels: {
            formatter: function(val) {
              return '$' + val.toLocaleString('en-US', { minimumFractionDigits: 4, maximumFractionDigits: 4 })
            },
            style: { fontSize: '11px', colors: '#6B7280' }
          }
        },
        tooltip: {
          y: {
            formatter: function(val) {
              return '$' + val.toLocaleString('en-US', { minimumFractionDigits: 4, maximumFractionDigits: 4 })
            }
          }
        },
        colors: ['#3B82F6'] // Blue color for the area
      }

      this.updateStatus(asset.symbol, 'Options created, creating chart instance...')

      try {
        const chart = new window.ApexCharts(chartElement, options)
        // Store chart reference for cleanup
        if (!this.charts) {
          this.charts = []
        }
        this.charts.push(chart)
        
        this.updateStatus(asset.symbol, 'Chart instance created, rendering...')

        chart.render().then(() => {
          console.log('✅ Chart rendered for ' + asset.symbol + '!')
          this.updateStatus(asset.symbol, '✅ Chart rendered successfully!')
          // Hide status after 2 seconds
          setTimeout(() => {
            const statusDiv = document.getElementById('status-' + asset.symbol)
            if (statusDiv) statusDiv.style.display = 'none'
          }, 2000)
        }).catch((error) => {
          console.error('Error rendering chart:', error)
          this.updateStatus(asset.symbol, 'ERROR: ' + error.message)
        })
      } catch (error) {
        console.error('Error creating chart:', error)
        this.updateStatus(asset.symbol, 'ERROR: ' + error.message)
      }
    })

    console.log('=== Chart creation complete ===')
  }

  updateStatus(symbol, message) {
    const statusEl = document.getElementById('status-text-' + symbol)
    if (statusEl) {
      statusEl.textContent = message
      console.log('Status for ' + symbol + ':', message)
    }
  }
}

