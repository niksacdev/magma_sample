# Sample: Visual Alignment Reasoning Using MAGMA

> **Note**: This is a **sample project** designed to demonstrate how to use multimodal foundation models like MAGMA for visual understanding and reasoning in robotic scenarios. It is intended for prototyping and experimentation purposes, particularly to evaluate the model’s ability to identify object and end-effector misalignment based solely on image inputs and structured prompts.

---

## Objective

This sample demonstrates how to evaluate the reasoning capabilities of MAGMA (hosted via Azure AI Foundry) in a typical industrial robotics scenario — a robotic arm attempting to grasp a red object. The model is presented with visual inputs depicting various states of misalignment between the robot’s gripper and the target object, and is prompted to analyze the scene and recommend corrective actions.

The goal is not to simulate physics, but to evaluate **prompt design**, **model interpretability**, and **image-based spatial reasoning**.

---

## Evaluation Setup

We provide a set of **6 high-resolution images**:
- 5 images showing **different types of misalignment** between a robotic gripper and a red block
- 1 image where the **gripper is properly aligned** to perform a successful grasp

These images are intended to simulate real-world snapshots from a robot’s camera or a technician’s field capture.

---

## Prompt Design Guidelines

For each image, MAGMA will be provided with a carefully structured prompt that sets context and requests a spatial reasoning response.

### ✅ Example Zero-Shot Prompt
```
You are assisting a robotic arm in a factory. The task is to grasp the red block on the platform.
Please look at the image and describe the alignment of the end effector. Suggest if a correction is needed.
```

### ✅ Example Chain-of-Thought (CoT) Prompt
```
Step 1: Describe the current position of the gripper with respect to the red block.
Step 2: Determine whether the alignment is correct for grasping.
Step 3: If not aligned, suggest a corrective movement.
Step 4: Output a JSON object in the format:
{
  "status": "aligned" | "misaligned",
  "correction": {
    "axis": "x|y|z|yaw",
    "direction": "left|right|up|down|clockwise|counterclockwise",
    "magnitude": "<number> degrees or cm"
  }
}
```

---

## How to Use This Sample

1. Select an image from the provided set (`misalignment_1.png` to `misalignment_5.png`, or `aligned.png`).
2. Encode the image in base64 and embed it in the `image_url` field as per Azure AI Foundry API format.
3. Attach your prompt text in the `messages` array.
4. Submit the request to the MAGMA model endpoint.
5. Log the result and compare it to the ground truth alignment status.

---

## Image List

| File Name              | Alignment Status | Description                        |
|------------------------|------------------|------------------------------------|
| `misalignment_1.png`  | Misaligned       | Gripper off-target to the left     |
| `misalignment_2.png`  | Misaligned       | Gripper rotated away from center   |
| `misalignment_3.png`  | Misaligned       | Gripper shifted forward            |
| `misalignment_4.png`  | Misaligned       | Gripper too high above object      |
| `misalignment_5.png`  | Misaligned       | Gripper angled but not centered    |
| `aligned.png`         | Aligned          | Correct pose over the red block    |

---

## Goal of the Sample

This sample is designed to:
- Help define effective prompts for MAGMA’s vision-language interface
- Evaluate the model’s ability to reason over robotic alignment tasks from a **single image + prompt**
- Create a foundation for future real-time scenarios such as robot supervision, co-pilot diagnostics, or factory agent assistance

---
