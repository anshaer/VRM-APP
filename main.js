import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { VRMLoaderPlugin } from '@pixiv/three-vrm';

const container = document.getElementById('canvas-container');
const scene = new THREE.Scene();

// 建立 9:16 相機
const camera = new THREE.PerspectiveCamera(30, 9 / 16, 0.1, 20);
camera.position.set(0, 1.4, 2.0); // 預設高度，後續會依據模型調整

const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
renderer.setSize(container.clientWidth, container.clientHeight);
renderer.setPixelRatio(window.devicePixelRatio);
container.insertBefore(renderer.domElement, document.getElementById('chat-overlay'));

// 光源
const light = new THREE.DirectionalLight(0xffffff, 1.0);
light.position.set(1.0, 1.0, 1.0).normalize();
scene.add(light);
scene.add(new THREE.AmbientLight(0xffffff, 0.5));

let currentVrm = null;

// 動態載入 VRM
window.loadVRM = function(event) {
  const file = event.target.files[0];
  if (!file) return;
  const url = URL.createObjectURL(file);
  
  const loader = new GLTFLoader();
  loader.register((parser) => new VRMLoaderPlugin(parser));
  
  loader.load(url, (gltf) => {
    if (currentVrm) { scene.remove(currentVrm.scene); }
    currentVrm = gltf.userData.vrm;
    scene.add(currentVrm.scene);
    
    // 預設面部對齊中心：將相機對準頭部骨骼
    const headNode = currentVrm.humanoid.getNormalizedBoneNode('head');
    if (headNode) {
      const headPos = new THREE.Vector3();
      headNode.getWorldPosition(headPos);
      camera.position.set(headPos.x, headPos.y, headPos.z + 1.2);
      camera.lookAt(headPos);
    }
  });
};

// 動態載入背景
window.loadBackground = function(event) {
  const file = event.target.files[0];
  if (!file) return;
  const url = URL.createObjectURL(file);
  const textureLoader = new THREE.TextureLoader();
  textureLoader.load(url, (texture) => {
    scene.background = texture;
  });
};

// 渲染迴圈
const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  const deltaTime = clock.getDelta();
  if (currentVrm) currentVrm.update(deltaTime);
  renderer.render(scene, camera);
}
animate();

// 視窗縮放適應
window.addEventListener('resize', () => {
  camera.aspect = container.clientWidth / container.clientHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(container.clientWidth, container.clientHeight);
});
