.main-container {
    position: relative;
    border-right: 1px solid #ccc;
    padding-top: 37px;
    background: #f2f3f3;
    overflow: hidden;
    width: 100%;
}

.positioned {
    position: absolute;
    top: 100px;
    left: 100px;
    width: 100%;
    box-shadow: 0 0 15px #333;
}

.container-new {
    overflow-y: auto;
}

.container-select {
    max-height: 160px;
}

.container-filter {
    max-height: 300px;
}

.result-table tr {
    background: #fff;
}

.result-table tr:hover {
    background: #e6f4ff;
}

.container-new table {
    border-spacing: 0;
    width: 100%;
}

.container-new td + td {
    border-bottom: 1px solid #ddd;
	text-align: center;
}

.container-new td, th {
    border-bottom: 1px solid #eee;
    color: #000;
    padding: 5px 12px;
}

.container-new th {
    height: 0;
    line-height: 0;
    padding-top: 0;
    padding-bottom: 0;
    color: transparent;
    border: solid 1px #ccc;
    white-space: nowrap;
}

.container-new th div {
    position: absolute;
    background: transparent;
    color: #000;
    padding: 12px 12px;
    top: 0;
    margin-left: -12px;
    line-height: normal;
    border: 1px solid #ddd;
    width:100%;
}

.container-new td:first-child {
    padding: 2px;
    text-align: center;
}
