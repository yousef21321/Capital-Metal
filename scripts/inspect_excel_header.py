#!/usr/bin/env python3
import sys
from openpyxl import load_workbook
from pathlib import Path
p = Path('/work/قائمة اسعار كايرو ميتال .xlsx')
wb = load_workbook(str(p), data_only=True)
sheet = wb.active
print([cell.value for cell in sheet[1]])
