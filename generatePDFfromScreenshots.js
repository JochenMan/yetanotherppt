const fs = require('fs');
const puppeteer = require('puppeteer');
const { PDFDocument } = require('pdf-lib');

async function generatePDFfromScreenshots(url, outputFilePath) {
  const browser = await puppeteer.launch({
    headless: 'new', // Opt-in to the new headless mode
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle0' });

  // Assuming Reveal.js is used and there's a way to get the total number of slides
  const totalSlides = await page.evaluate(() => {
    return Reveal.getTotalSlides();
  });

  const pdfDoc = await PDFDocument.create();

  for (let i = 0; i < totalSlides; i++) {
    // Log
    console.log(`Taking screenshot of slide: ${i}`);

    // Navigate to the correct slide
    await page.evaluate((slideIndex) => Reveal.slide(slideIndex), i);
    await page.waitForTimeout(2000); // Wait for any transitions or animations

    const slideImageBuffer = await page.screenshot();
    const slideImage = await pdfDoc.embedPng(slideImageBuffer);

    // Add a page to the PDF for this slide
    const pdfPage = pdfDoc.addPage([slideImage.width, slideImage.height]);
    pdfPage.drawImage(slideImage, {
      x: 0,
      y: 0,
      width: slideImage.width,
      height: slideImage.height,
    });
  }

  const pdfBytes = await pdfDoc.save();
  fs.writeFileSync(outputFilePath, pdfBytes);

  await browser.close();
}

const presentationURL = 'http://localhost:8080/presentation.html';
const outputPDFPath = 'presentation.pdf';

(async () => {
  await generatePDFfromScreenshots(presentationURL, outputPDFPath);
})();
