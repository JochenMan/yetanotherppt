#!/usr/bin/env node

// PDF generator using Puppeteer - screenshots each slide individually
const puppeteer = require('puppeteer');
const fs = require('fs');

async function generatePDF(presentationUrl, outputPath) {
    console.log('Generating PDF from individual slide screenshots...');

    try {
        const browser = await puppeteer.launch({
            executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-gpu',
                '--disable-extensions',
                '--no-first-run'
            ],
            headless: true
        });

        const page = await browser.newPage();

        // Set viewport to presentation size for clean screenshots
        await page.setViewport({ width: 1920, height: 1080 });

        console.log(`Loading presentation: ${presentationUrl}`);

        // Load normal presentation mode
        await page.goto(presentationUrl, {
            waitUntil: 'networkidle0',
            timeout: 30000
        });

        // Wait for Reveal.js to load
        await page.waitForSelector('.reveal .slides', { timeout: 15000 });
        await page.waitForTimeout(3000);

        console.log('Taking screenshots of each slide...');

        // Get total number of slides
        const slideCount = await page.evaluate(() => {
            return Reveal.getTotalSlides();
        });

        console.log(`Found ${slideCount} slides`);

        // Create HTML content with all slide screenshots
        let htmlContent = `
        <html>
        <head>
            <style>
                @page {
                    size: A4 landscape;
                    margin: 0;
                }
                body {
                    margin: 0;
                    padding: 0;
                    font-family: Arial, sans-serif;
                }
                .slide-page {
                    width: 100vw;
                    height: 100vh;
                    margin: 0;
                    padding: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    page-break-after: always;
                }
                .slide-page:last-child {
                    page-break-after: avoid;
                }
                .slide-page img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                }
            </style>
        </head>
        <body>`;

        // Disable transitions for faster slide changes
        await page.evaluate(() => {
            Reveal.configure({ transition: 'none' });
        });

        // Capture each slide as screenshot
        for (let i = 0; i < slideCount; i++) {
            console.log(`Capturing slide ${i + 1}/${slideCount}`);

            // Navigate to slide
            await page.evaluate((slideIndex) => {
                Reveal.slide(slideIndex);
            }, i);

            // Wait for slide to render
            await page.waitForTimeout(100);

            // Take screenshot of current slide
            const screenshot = await page.screenshot({
                type: 'png',
                fullPage: false,
                encoding: 'base64'
            });

            // Add slide as full-page image
            htmlContent += `
                <div class="slide-page">
                    <img src="data:image/png;base64,${screenshot}" alt="Slide ${i + 1}">
                </div>`;
        }

        htmlContent += '</body></html>';

        // Create new page for PDF generation
        const pdfPage = await browser.newPage();
        await pdfPage.setContent(htmlContent);
        await pdfPage.waitForTimeout(2000);

        console.log('Converting screenshots to PDF...');

        // Generate PDF from screenshots
        const pdfBuffer = await pdfPage.pdf({
            format: 'A4',
            landscape: true,
            printBackground: true,
            margin: { top: 0, bottom: 0, left: 0, right: 0 },
            displayHeaderFooter: false
        });

        // Save PDF
        fs.writeFileSync(outputPath, pdfBuffer);

        await browser.close();
        console.log(`PDF successfully saved: ${outputPath}`);

    } catch (error) {
        console.error('PDF generation failed:', error.message);
        console.error('Stack trace:', error.stack);

        // Create error file
        const errorMsg = `PDF Generation Failed\nError: ${error.message}\nTime: ${new Date().toISOString()}`;
        fs.writeFileSync(outputPath.replace('.pdf', '_error.txt'), errorMsg);
        console.log('Error log saved as presentation_error.txt');
    }
}

// Run if called directly
if (require.main === module) {
    const url = process.argv[2] || 'http://localhost/presentation.html';
    const output = process.argv[3] || '/usr/share/nginx/html/presentation.pdf';

    generatePDF(url, output);
}

module.exports = { generatePDF };