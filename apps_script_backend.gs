const SPREADSHEET_ID = "1bIXdff1V6CQ74wdOtMq7lCtRbpPjowKgrfgH03UczOM";
const SHEET_NAME = "Groceries";

function doGet(e) {
  try {
    const path = getPath(e);

    if (path === "list") {
      return handleList();
    }

    return jsonResponse({ success: false, message: "Unknown route: " + path }, 404);
  } catch (error) {
    return jsonResponse({ success: false, message: error.message }, 500);
  }
}

function doPost(e) {
  try {
    const path = getPath(e);

    if (path === "add") {
      return handleAdd(e);
    }

    if (path === "update") {
      return handleUpdate(e);
    }

    return jsonResponse({ success: false, message: "Unknown route: " + path }, 404);
  } catch (error) {
    return jsonResponse({ success: false, message: error.message }, 500);
  }
}

function getPath(e) {
  if (!e || !e.parameter || !e.parameter.path) {
    return "";
  }
  return String(e.parameter.path).trim().toLowerCase();
}

function handleList() {
  const sheet = getSheet();
  const values = sheet.getDataRange().getValues();

  if (values.length <= 1) {
    return jsonResponse({ success: true, data: [] });
  }

  const data = [];

  for (let i = 1; i < values.length; i++) {
    const row = values[i];

    if (!row[1]) {
      continue;
    }

    data.push({
      rowIndex: i + 1,
      timestamp: formatTimestamp(row[0]),
      item: String(row[1]),
      quantity: Number(row[2]) || 0,
      cost: Number(row[3]) || 0,
      boughtBy: String(row[4] || "")
    });
  }

  data.sort(function (a, b) {
    return String(b.timestamp).localeCompare(String(a.timestamp));
  });

  return jsonResponse({ success: true, data: data });
}

function handleAdd(e) {
  if (!e || !e.postData || !e.postData.contents) {
    return jsonResponse({ success: false, message: "Request body is required" }, 400);
  }

  let payload;

  try {
    payload = JSON.parse(e.postData.contents);
  } catch (error) {
    return jsonResponse({ success: false, message: "Invalid JSON body" }, 400);
  }

  const item = String(payload.item || "").trim();
  const quantity = Number(payload.quantity);
  const cost = Number(payload.cost);
  const boughtBy = String(payload.boughtBy || "").trim();

  if (!item) {
    return jsonResponse({ success: false, message: "Item is required" }, 400);
  }

  if (!boughtBy) {
    return jsonResponse({ success: false, message: "BoughtBy is required" }, 400);
  }

  if (!quantity || quantity <= 0) {
    return jsonResponse({ success: false, message: "Quantity must be greater than 0" }, 400);
  }

  if (!cost || cost <= 0) {
    return jsonResponse({ success: false, message: "Cost must be greater than 0" }, 400);
  }

  const sheet = getSheet();
  const timestamp = Utilities.formatDate(
    new Date(),
    Session.getScriptTimeZone(),
    "yyyy-MM-dd HH:mm"
  );

  sheet.appendRow([timestamp, item, quantity, cost, boughtBy]);

  return jsonResponse({ success: true });
}

function handleUpdate(e) {
  if (!e || !e.postData || !e.postData.contents) {
    return jsonResponse({ success: false, message: "Request body is required" }, 400);
  }

  let payload;

  try {
    payload = JSON.parse(e.postData.contents);
  } catch (error) {
    return jsonResponse({ success: false, message: "Invalid JSON body" }, 400);
  }

  let rowIndex = Number(payload.rowIndex);
  const hasRowIndex = Number.isInteger(rowIndex) && rowIndex >= 2;
  const item = String(payload.item || "").trim();
  const quantity = Number(payload.quantity);
  const cost = Number(payload.cost);
  const boughtBy = String(payload.boughtBy || "").trim();

  if (!item) {
    return jsonResponse({ success: false, message: "Item is required" }, 400);
  }

  if (!boughtBy) {
    return jsonResponse({ success: false, message: "BoughtBy is required" }, 400);
  }

  if (!quantity || quantity <= 0) {
    return jsonResponse({ success: false, message: "Quantity must be greater than 0" }, 400);
  }

  if (!cost || cost <= 0) {
    return jsonResponse({ success: false, message: "Cost must be greater than 0" }, 400);
  }

  const sheet = getSheet();

  if (!hasRowIndex) {
    rowIndex = findRowIndexByOriginalItem(sheet, payload);
    if (!rowIndex) {
      return jsonResponse({ success: false, message: "Item not found for editing. Please refresh and try again." }, 404);
    }
  }

  const lastRow = sheet.getLastRow();

  if (rowIndex > lastRow) {
    return jsonResponse({ success: false, message: "Item not found" }, 404);
  }

  const timestamp = Utilities.formatDate(
    new Date(),
    Session.getScriptTimeZone(),
    "yyyy-MM-dd HH:mm"
  );

  sheet.getRange(rowIndex, 1, 1, 5).setValues([[timestamp, item, quantity, cost, boughtBy]]);

  return jsonResponse({ success: true });
}

function findRowIndexByOriginalItem(sheet, payload) {
  const originalTimestamp = String(payload.originalTimestamp || "").trim();
  const originalItem = String(payload.originalItem || "").trim();
  const originalQuantity = Number(payload.originalQuantity);
  const originalCost = Number(payload.originalCost);
  const originalBoughtBy = String(payload.originalBoughtBy || "").trim();

  if (!originalTimestamp || !originalItem || !originalBoughtBy) {
    return null;
  }

  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    const rowTimestamp = formatTimestamp(row[0]);
    const rowItem = String(row[1] || "").trim();
    const rowQuantity = Number(row[2]) || 0;
    const rowCost = Number(row[3]) || 0;
    const rowBoughtBy = String(row[4] || "").trim();

    if (
      rowTimestamp === originalTimestamp &&
      rowItem === originalItem &&
      rowQuantity === originalQuantity &&
      rowCost === originalCost &&
      rowBoughtBy === originalBoughtBy
    ) {
      return i + 1;
    }
  }

  return null;
}

function getSheet() {
  const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
  let sheet = spreadsheet.getSheetByName(SHEET_NAME);

  if (!sheet) {
    sheet = spreadsheet.insertSheet(SHEET_NAME);
    sheet.appendRow(["Timestamp", "Item", "Quantity", "Cost", "BoughtBy"]);
  }

  return sheet;
}

function formatTimestamp(value) {
  if (!value) {
    return "";
  }

  if (value instanceof Date) {
    return Utilities.formatDate(
      value,
      Session.getScriptTimeZone(),
      "yyyy-MM-dd HH:mm"
    );
  }

  return String(value);
}

function jsonResponse(body, statusCode) {
  const output = ContentService.createTextOutput(JSON.stringify(body));
  output.setMimeType(ContentService.MimeType.JSON);

  if (statusCode) {
    // Apps Script web apps do not support custom HTTP status codes directly.
    // The statusCode parameter is kept for clarity in the source code.
  }

  return output;
}
