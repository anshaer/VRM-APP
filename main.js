// 初始化變數
let scene, camera, renderer, currentVrm, clock;

init3D();

function init3D() {
  const container = document.querySelector('.stream-container');
  const canvas = document.querySelector('#canvas3d');
  clock = new THREE.Clock();

  // 1. 建立場景
  scene = new THREE.Scene();

  // 2. 建立相機 (配合 9:16 比例)
  const width = container.clientWidth;
  const height = container.clientHeight;
  camera = new THREE.PerspectiveCamera(30, width / height, 0.1, 20.0);
  camera.position.set(0.0, 1.4, 1.4); // 預設對準上半身與臉部

  // 3. 建立渲染器 (設定透明度，以便未來支援自訂背景圖)
  renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.outputEncoding = THREE.sRGBEncoding;

  // 4. 加入光源
  const light = new THREE.DirectionalLight(0xffxfff, 1.0);
  light.position.set(1.0, 1.0, 1.0).normalize();
  scene.add(light);
  
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
  scene.add(ambientLight);

  // 5. 啟動動畫循環
  animate();

  // 監聽視窗縮放
  window.addEventListener('resize', onWindowResize);
}

// 動態更新畫布尺寸
function onWindowResize() {
  const container = document.querySelector('.stream-container');
  const width = container.clientWidth;
  const height = container.clientHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  renderer.setSize(width, height);
}

// 監聽檔案上傳
document.getElementById('fileInput').addEventListener('change', (event) => {
  const file = event.target.files[0];
  if (!file) return;

  const blob = new Blob([file], { type: "application/octet-stream" });
  const url = URL.createObjectURL(blob);

  loadVRM(url);
});

// 載入 VRM 模型主函式
function loadVRM(url) {
  // 如果場景已有模型，先移除
  if (currentVrm) {
    scene.remove(currentVrm.scene);
    THREE.VRMUtils.deepDispose(currentVrm.scene);
  }

  const loader = new THREE.GLTFLoader();
  
  // 註冊三維 VRM 插件
  loader.register((parser) => {
    return new THREE_VRM.VRMLoaderPlugin(parser);
  });

  loader.load(
    url,
    (gltf) => {
      const vrm = gltf.userData.vrm;
      currentVrm = vrm;
      scene.add(vrm.scene);

      // 修正模型朝向，使其面對相機
      vrm.scene.rotation.y = Math.PI; 
      
      // 調整模型位置，讓鏡頭聚焦在胸部到頭部
      vrm.scene.position.set(0, 0, 0);

      console.log("VRM 載入成功:", vrm);
    },
    (progress) => console.log(`載入進度: ${(progress.loaded / progress.total * 100).toFixed(2)}%`),
    (error) => console.error("載入失敗:", error)
  );
}

// 每秒更新渲染
function animate() {
  requestAnimationFrame(animate);

  const deltaTime = clock.getDelta();
  if (currentVrm) {
    // 未來在這邊更新 MediaPipe / Kalidokit 的人臉追蹤數據
    currentVrm.update(deltaTime);
  }

  renderer.render(scene, camera);
}
