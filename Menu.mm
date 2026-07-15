<!-- palofsc: FLU FF CYBER MENU - FOV & ESP (đã sửa lỗi) -->
<!-- Sửa: thiếu dấu xuống dòng trước function drawFOV(), thiếu classList toggle -->
<!-- Lưu thành .html, mở trình duyệt để xem giao diện -->

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>FLU FF CYBER MENU - FOV & ESP</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #0a0a0f;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            overflow: hidden;
            user-select: none;
            -webkit-user-select: none;
        }

        /* Canvas vẽ vòng FOV */
        #fovCanvas {
            position: absolute;
            top: 0; left: 0; width: 100vw; height: 100vh;
            pointer-events: none;
            z-index: 1;
        }

        /* Khung bọc hiệu ứng viền LED chạy vòng quanh */
        .menu-border-glow {
            position: relative;
            padding: 2px;
            border-radius: 20px;
            overflow: hidden;
            background: rgba(0, 0, 0, 0.5);
            box-shadow: 0 0 30px rgba(0, 242, 254, 0.2);
            transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), opacity 0.2s ease;
            transform: scale(0);
            opacity: 0;
            pointer-events: none;
            z-index: 10;
        }

        .menu-border-glow.active {
            transform: scale(1);
            opacity: 1;
            pointer-events: auto;
        }

        .menu-border-glow::before {
            content: '';
            position: absolute;
            top: -50%; left: -50%; width: 200%; height: 200%;
            background: conic-gradient(from 0deg, transparent, #ff007f, #00f2fe, transparent 60%);
            animation: rotateRGB 4s linear infinite;
            z-index: 1;
        }

        @keyframes rotateRGB {
            100% { transform: rotate(360deg); }
        }

        /* Ruột Menu chính */
        .menu-wrapper {
            position: relative;
            z-index: 2;
            width: 90vw;
            max-width: 420px;
            background: rgba(10, 10, 18, 0.98);
            backdrop-filter: blur(25px);
            border-radius: 18px;
            padding: 15px 20px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .brand {
            font-weight: 900;
            font-size: 16px;
            letter-spacing: 2px;
            text-transform: uppercase;
            background: linear-gradient(90deg, #ff007f, #00f2fe);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 0 0 10px rgba(0, 242, 254, 0.4);
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 10px;
        }

        .menu-content {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .menu-item {
            background: linear-gradient(135deg, #151525, #0d0d18);
            border-radius: 12px;
            padding: 10px 15px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s;
        }

        .menu-item:hover {
            border-color: rgba(0, 242, 254, 0.3);
        }

        .item-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .menu-item .icon { font-size: 18px; }
        .menu-item .label {
            font-size: 13px;
            color: #e0e0e3;
            font-weight: 600;
        }

        .fov-container {
            background: rgba(255, 255, 255, 0.02);
            border-radius: 12px;
            padding: 12px;
            border: 1px dashed rgba(0, 242, 254, 0.2);
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .fov-header {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #00f2fe;
            font-weight: bold;
        }

        .range-slider {
            -webkit-appearance: none;
            width: 100%;
            height: 6px;
            background: #252535;
            border-radius: 5px;
            outline: none;
        }

        .range-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: #00f2fe;
            box-shadow: 0 0 8px #00f2fe;
            cursor: pointer;
        }

        .switch { position: relative; width: 34px; height: 18px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0;
            background-color: #252535; border-radius: 20px; transition: 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .slider:before {
            position: absolute; content: ""; height: 12px; width: 12px;
            left: 2px; bottom: 2px; background-color: #777; border-radius: 50%;
            transition: 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }
        input:checked + .slider {
            background-color: rgba(0, 242, 254, 0.1); border-color: #00f2fe;
            box-shadow: 0 0 10px rgba(0, 242, 254, 0.4);
        }
        input:checked + .slider:before {
            transform: translateX(16px); background-color: #00f2fe; box-shadow: 0 0 8px #00f2fe;
        }

        .hint-text {
            position: absolute; bottom: 20px; color: rgba(255, 255, 255, 0.3);
            font-size: 11px; letter-spacing: 1px; pointer-events: none; transition: opacity 0.5s;
        }
    </style>
</head>
<body>

    <canvas id="fovCanvas"></canvas>

    <div class="hint-text" id="hint">✌️ Chạm 2 ngón tay cùng lúc để bật/tắt menu FLU</div>

    <div class="menu-border-glow" id="menuBox">
        <div class="menu-wrapper">
            <div class="brand">🔥 FLU FF VIP v2</div>
            
            <div class="menu-content">
                <!-- Aimbot -->
                <div class="menu-item">
                    <div class="item-left">
                        <span class="icon">🎯</span>
                        <span class="label">Chức năng Aimbot</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="aimbot" checked>
                        <span class="slider"></span>
                    </label>
                </div>

                <!-- FOV -->
                <div class="fov-container">
                    <div class="fov-header">
                        <span>Phạm vi Vòng FOV</span>
                        <span id="fovVal">100px</span>
                    </div>
                    <input type="range" id="fovSlider" class="range-slider" min="30" max="300" value="100">
                    
                    <div class="fov-header" style="margin-top: 5px;">
                        <span style="color: #aaa;">Hiển thị vòng tròn FOV</span>
                        <label class="switch">
                            <input type="checkbox" id="drawFov" checked>
                            <span class="slider"></span>
                        </label>
                    </div>
                </div>

                <!-- ESP -->
                <div class="menu-item">
                    <div class="item-left">
                        <span class="icon">👁️</span>
                        <span class="label">Bật định vị ESP (Khung/Line)</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="esp" checked>
                        <span class="slider"></span>
                    </label>
                </div>

                <!-- AntiBan -->
                <div class="menu-item">
                    <div class="item-left">
                        <span class="icon">🛡️</span>
                        <span class="label">Bảo mật AntiBan ẩn danh</span>
                    </div>
                    <label class="switch">
                        <input type="checkbox" id="antiban" checked>
                        <span class="slider"></span>
                    </label>
                </div>
            </div>
        </div>
    </div>

    <script>
        const menuBox = document.getElementById('menuBox');
        const hint = document.getElementById('hint');
        const canvas = document.getElementById('fovCanvas');
        const ctx = canvas.getContext('2d');

        const fovSlider = document.getElementById('fovSlider');
        const fovVal = document.getElementById('fovVal');
        const drawFovCheck = document.getElementById('drawFov');

        // Căn chỉnh Canvas
        function resizeCanvas() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            drawFOV();
        }
        window.addEventListener('resize', resizeCanvas);
        setTimeout(resizeCanvas, 100);

        // Vẽ vòng FOV
        function drawFOV() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            if (drawFovCheck.checked) {
                const centerX = canvas.width / 2;
                const centerY = canvas.height / 2;
                const radius = parseInt(fovSlider.value);
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                ctx.lineWidth = 1.5;
                ctx.strokeStyle = '#00f2fe';
                ctx.shadowBlur = 8;
                ctx.shadowColor = '#00f2fe';
                ctx.stroke();
            }
        }

        fovSlider.addEventListener('input', (e) => {
            fovVal.innerText = e.target.value + "px";
            drawFOV();
            sendDataToDylib("fov_size", e.target.value);
        });

        drawFovCheck.addEventListener('change', () => {
            drawFOV();
            sendDataToDylib("draw_fov", drawFovCheck.checked);
        });

        // Bắt tất cả checkbox
        document.querySelectorAll('input[type="checkbox"]').forEach(item => {
            item.addEventListener('change', () => {
                sendDataToDylib(item.id, item.checked);
            });
        });

        // Gửi dữ liệu sang dylib (nếu có)
        function sendDataToDylib(featureId, value) {
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.FLUHandler) {
                window.webkit.messageHandlers.FLUHandler.postMessage({
                    feature: featureId,
                    status: value
                });
            }
        }

        // Chạm 2 ngón để bật/tắt menu
        window.addEventListener('touchstart', function(e) {
            if (e.touches.length === 2) {
                e.preventDefault();
                menuBox.classList.toggle('active');
                if (hint) hint.style.opacity = '0';
            }
        }, { passive: false });
    </script>
</body>
</html>
