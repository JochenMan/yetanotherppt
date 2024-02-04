const fs = require('fs');
const puppeteer = require('puppeteer');
const { PDFDocument } = require('pdf-lib');

// Function to generate a black and white PDF
async function generateBlackAndWhitePDF(url, outputFilePath) {
  const browser = await puppeteer.launch({
    headless: 'new', // Opt-in to the new headless mode
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Consider security implications
  });
  //const page = await browser.newPage();
  const page = await browser.newPage();
  await page.setViewport({
    width: 1920,
    height: 1080,
    deviceScaleFactor: 2, // Increase this for higher resolution screenshots
  });

  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.emulateMediaType('screen');
  await page.pdf({ path: outputFilePath, format: 'A4', printBackground: true });
  await browser.close();
}

// Function to take screenshots and stitch them into a color PDF
async function generateColorPDF(url, outputFilePath) {
  const browser = await puppeteer.launch({
    headless: 'new', // As per the new headless mode
    args: ['--no-sandbox', '--disable-setuid-sandbox'] // Consider security implications
  });
  //const page = await browser.newPage();
  const page = await browser.newPage();
  await page.setViewport({
    width: 1920,
    height: 1080,
    deviceScaleFactor: 2, // Increase this for higher resolution screenshots
  });

  await page.goto(url, { waitUntil: 'networkidle0' });

  // Dynamically count the total number of slides
  const totalSlides = await page.evaluate(() => {
    return Reveal.getTotalSlides();
  });

  const pdfDoc = await PDFDocument.create();

  for (let i = 0; i < totalSlides; i++) {
    console.log(`Taking screenshot of slide: ${i}`);
    // Navigate to the correct slide using Reveal.js's functionality
    await page.evaluate((slideIndex) => Reveal.slide(slideIndex), i);
    await page.waitForTimeout(2000); // Wait for the slide transition and any animations

    const slideImage = await page.screenshot({ fullPage: true });
    const image = await pdfDoc.embedPng(slideImage);

    // Use a different variable name for the PDF page to avoid conflict
    const pdfPage = pdfDoc.addPage([image.width, image.height]);
    pdfPage.drawImage(image, { x: 0, y: 0, width: image.width, height: image.height });
  }

  const pdfBytes = await pdfDoc.save();
  fs.writeFileSync(outputFilePath, pdfBytes);
  await browser.close();
}

// URLs and paths should be adjusted as per your requirement
// const presentationURL = 'http://host.docker.internal:8080/presentation.html';
const bwPresentationURL = 'http://localhost:8080/presentation.html?print-pdf';
const colorPresentationURL = 'http://localhost:8080/presentation.html';
const blackAndWhitePDFPath = 'presentation_bw.pdf';
const colorPDFPath = 'presentation_color.pdf';
// const totalSlides = 4; // Adjust this to match the total number of slides in your presentation

(async () => {
  await generateBlackAndWhitePDF(bwPresentationURL, blackAndWhitePDFPath);
  await generateColorPDF(colorPresentationURL, colorPDFPath);
})();
