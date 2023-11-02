
#include "dawn/dawn_proc.h"
#include "mach_dawn.h"
#include <stdbool.h>
#include <stdio.h>

static DawnProcTable procs;
static DawnProcTable nullProcs;

void dawnSetupGlobalProcs() {
    procs = machDawnGetProcTable();
}

void dawnProcSetProcs(const DawnProcTable* procs_) {
    if (procs_) {
        procs = *procs_;
    } else {
        procs = nullProcs;
    }
}

WGPUInstance wgpuCreateInstance(WGPUInstanceDescriptor const * descriptor) {
return     procs.createInstance(descriptor);
}
WGPUProc wgpuGetProcAddress(WGPUDevice device, char const * procName) {
return     procs.getProcAddress(device, procName);
}

WGPUDevice wgpuAdapterCreateDevice(WGPUAdapter adapter, WGPUDeviceDescriptor const * descriptor) {
return     procs.adapterCreateDevice(adapter, descriptor);
}
size_t wgpuAdapterEnumerateFeatures(WGPUAdapter adapter, WGPUFeatureName * features) {
return     procs.adapterEnumerateFeatures(adapter, features);
}
WGPUInstance wgpuAdapterGetInstance(WGPUAdapter adapter) {
return     procs.adapterGetInstance(adapter);
}
// bool wgpuAdapterGetLimits(WGPUAdapter adapter, WGPUSupportedLimits * limits) {
// return     procs.adapterGetLimits(adapter, limits);
// }
void wgpuAdapterGetProperties(WGPUAdapter adapter, WGPUAdapterProperties * properties) {
    procs.adapterGetProperties(adapter, properties);
}
// bool wgpuAdapterHasFeature(WGPUAdapter adapter, WGPUFeatureName feature) {
// return     procs.adapterHasFeature(adapter, feature);
// }
void wgpuAdapterRequestDevice(WGPUAdapter adapter, WGPUDeviceDescriptor const * descriptor, WGPURequestDeviceCallback callback, void * userdata) {
    procs.adapterRequestDevice(adapter, descriptor, callback, userdata);
}
void wgpuAdapterReference(WGPUAdapter adapter) {
    procs.adapterReference(adapter);
}
void wgpuAdapterRelease(WGPUAdapter adapter) {
    procs.adapterRelease(adapter);
}

void wgpuBindGroupSetLabel(WGPUBindGroup bindGroup, char const * label) {
    procs.bindGroupSetLabel(bindGroup, label);
}
void wgpuBindGroupReference(WGPUBindGroup bindGroup) {
    procs.bindGroupReference(bindGroup);
}
void wgpuBindGroupRelease(WGPUBindGroup bindGroup) {
    procs.bindGroupRelease(bindGroup);
}

void wgpuBindGroupLayoutSetLabel(WGPUBindGroupLayout bindGroupLayout, char const * label) {
    procs.bindGroupLayoutSetLabel(bindGroupLayout, label);
}
void wgpuBindGroupLayoutReference(WGPUBindGroupLayout bindGroupLayout) {
    procs.bindGroupLayoutReference(bindGroupLayout);
}
void wgpuBindGroupLayoutRelease(WGPUBindGroupLayout bindGroupLayout) {
    procs.bindGroupLayoutRelease(bindGroupLayout);
}

void wgpuBufferDestroy(WGPUBuffer buffer) {
    procs.bufferDestroy(buffer);
}
void const * wgpuBufferGetConstMappedRange(WGPUBuffer buffer, size_t offset, size_t size) {
return     procs.bufferGetConstMappedRange(buffer, offset, size);
}
WGPUBufferMapState wgpuBufferGetMapState(WGPUBuffer buffer) {
return     procs.bufferGetMapState(buffer);
}
void * wgpuBufferGetMappedRange(WGPUBuffer buffer, size_t offset, size_t size) {
return     procs.bufferGetMappedRange(buffer, offset, size);
}
uint64_t wgpuBufferGetSize(WGPUBuffer buffer) {
return     procs.bufferGetSize(buffer);
}
WGPUBufferUsageFlags wgpuBufferGetUsage(WGPUBuffer buffer) {
return     procs.bufferGetUsage(buffer);
}
void wgpuBufferMapAsync(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapCallback callback, void * userdata) {
    procs.bufferMapAsync(buffer, mode, offset, size, callback, userdata);
}
void wgpuBufferSetLabel(WGPUBuffer buffer, char const * label) {
    procs.bufferSetLabel(buffer, label);
}
void wgpuBufferUnmap(WGPUBuffer buffer) {
    procs.bufferUnmap(buffer);
}
void wgpuBufferReference(WGPUBuffer buffer) {
    procs.bufferReference(buffer);
}
void wgpuBufferRelease(WGPUBuffer buffer) {
    procs.bufferRelease(buffer);
}

void wgpuCommandBufferSetLabel(WGPUCommandBuffer commandBuffer, char const * label) {
    procs.commandBufferSetLabel(commandBuffer, label);
}
void wgpuCommandBufferReference(WGPUCommandBuffer commandBuffer) {
    procs.commandBufferReference(commandBuffer);
}
void wgpuCommandBufferRelease(WGPUCommandBuffer commandBuffer) {
    procs.commandBufferRelease(commandBuffer);
}

WGPUComputePassEncoder wgpuCommandEncoderBeginComputePass(WGPUCommandEncoder commandEncoder, WGPUComputePassDescriptor const * descriptor) {
return     procs.commandEncoderBeginComputePass(commandEncoder, descriptor);
}
WGPURenderPassEncoder wgpuCommandEncoderBeginRenderPass(WGPUCommandEncoder commandEncoder, WGPURenderPassDescriptor const * descriptor) {
return     procs.commandEncoderBeginRenderPass(commandEncoder, descriptor);
}
void wgpuCommandEncoderClearBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size) {
    procs.commandEncoderClearBuffer(commandEncoder, buffer, offset, size);
}
void wgpuCommandEncoderCopyBufferToBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size) {
    procs.commandEncoderCopyBufferToBuffer(commandEncoder, source, sourceOffset, destination, destinationOffset, size);
}
void wgpuCommandEncoderCopyBufferToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize) {
    procs.commandEncoderCopyBufferToTexture(commandEncoder, source, destination, copySize);
}
void wgpuCommandEncoderCopyTextureToBuffer(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyBuffer const * destination, WGPUExtent3D const * copySize) {
    procs.commandEncoderCopyTextureToBuffer(commandEncoder, source, destination, copySize);
}
void wgpuCommandEncoderCopyTextureToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize) {
    procs.commandEncoderCopyTextureToTexture(commandEncoder, source, destination, copySize);
}
// void wgpuCommandEncoderCopyTextureToTextureInternal(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize) {
//     procs.commandEncoderCopyTextureToTextureInternal(commandEncoder, source, destination, copySize);
// }
WGPUCommandBuffer wgpuCommandEncoderFinish(WGPUCommandEncoder commandEncoder, WGPUCommandBufferDescriptor const * descriptor) {
return     procs.commandEncoderFinish(commandEncoder, descriptor);
}
void wgpuCommandEncoderInjectValidationError(WGPUCommandEncoder commandEncoder, char const * message) {
    procs.commandEncoderInjectValidationError(commandEncoder, message);
}
void wgpuCommandEncoderInsertDebugMarker(WGPUCommandEncoder commandEncoder, char const * markerLabel) {
    procs.commandEncoderInsertDebugMarker(commandEncoder, markerLabel);
}
void wgpuCommandEncoderPopDebugGroup(WGPUCommandEncoder commandEncoder) {
    procs.commandEncoderPopDebugGroup(commandEncoder);
}
void wgpuCommandEncoderPushDebugGroup(WGPUCommandEncoder commandEncoder, char const * groupLabel) {
    procs.commandEncoderPushDebugGroup(commandEncoder, groupLabel);
}
void wgpuCommandEncoderResolveQuerySet(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset) {
    procs.commandEncoderResolveQuerySet(commandEncoder, querySet, firstQuery, queryCount, destination, destinationOffset);
}
void wgpuCommandEncoderSetLabel(WGPUCommandEncoder commandEncoder, char const * label) {
    procs.commandEncoderSetLabel(commandEncoder, label);
}
void wgpuCommandEncoderWriteBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t bufferOffset, uint8_t const * data, uint64_t size) {
    procs.commandEncoderWriteBuffer(commandEncoder, buffer, bufferOffset, data, size);
}
void wgpuCommandEncoderWriteTimestamp(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex) {
    procs.commandEncoderWriteTimestamp(commandEncoder, querySet, queryIndex);
}
void wgpuCommandEncoderReference(WGPUCommandEncoder commandEncoder) {
    procs.commandEncoderReference(commandEncoder);
}
void wgpuCommandEncoderRelease(WGPUCommandEncoder commandEncoder) {
    procs.commandEncoderRelease(commandEncoder);
}

void wgpuComputePassEncoderDispatchWorkgroups(WGPUComputePassEncoder computePassEncoder, uint32_t workgroupCountX, uint32_t workgroupCountY, uint32_t workgroupCountZ) {
    procs.computePassEncoderDispatchWorkgroups(computePassEncoder, workgroupCountX, workgroupCountY, workgroupCountZ);
}
void wgpuComputePassEncoderDispatchWorkgroupsIndirect(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) {
    procs.computePassEncoderDispatchWorkgroupsIndirect(computePassEncoder, indirectBuffer, indirectOffset);
}
void wgpuComputePassEncoderEnd(WGPUComputePassEncoder computePassEncoder) {
    procs.computePassEncoderEnd(computePassEncoder);
}
void wgpuComputePassEncoderInsertDebugMarker(WGPUComputePassEncoder computePassEncoder, char const * markerLabel) {
    procs.computePassEncoderInsertDebugMarker(computePassEncoder, markerLabel);
}
void wgpuComputePassEncoderPopDebugGroup(WGPUComputePassEncoder computePassEncoder) {
    procs.computePassEncoderPopDebugGroup(computePassEncoder);
}
void wgpuComputePassEncoderPushDebugGroup(WGPUComputePassEncoder computePassEncoder, char const * groupLabel) {
    procs.computePassEncoderPushDebugGroup(computePassEncoder, groupLabel);
}
void wgpuComputePassEncoderSetBindGroup(WGPUComputePassEncoder computePassEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) {
    procs.computePassEncoderSetBindGroup(computePassEncoder, groupIndex, group, dynamicOffsetCount, dynamicOffsets);
}
void wgpuComputePassEncoderSetLabel(WGPUComputePassEncoder computePassEncoder, char const * label) {
    procs.computePassEncoderSetLabel(computePassEncoder, label);
}
void wgpuComputePassEncoderSetPipeline(WGPUComputePassEncoder computePassEncoder, WGPUComputePipeline pipeline) {
    procs.computePassEncoderSetPipeline(computePassEncoder, pipeline);
}
void wgpuComputePassEncoderWriteTimestamp(WGPUComputePassEncoder computePassEncoder, WGPUQuerySet querySet, uint32_t queryIndex) {
    procs.computePassEncoderWriteTimestamp(computePassEncoder, querySet, queryIndex);
}
void wgpuComputePassEncoderReference(WGPUComputePassEncoder computePassEncoder) {
    procs.computePassEncoderReference(computePassEncoder);
}
void wgpuComputePassEncoderRelease(WGPUComputePassEncoder computePassEncoder) {
    procs.computePassEncoderRelease(computePassEncoder);
}

WGPUBindGroupLayout wgpuComputePipelineGetBindGroupLayout(WGPUComputePipeline computePipeline, uint32_t groupIndex) {
return     procs.computePipelineGetBindGroupLayout(computePipeline, groupIndex);
}
void wgpuComputePipelineSetLabel(WGPUComputePipeline computePipeline, char const * label) {
    procs.computePipelineSetLabel(computePipeline, label);
}
void wgpuComputePipelineReference(WGPUComputePipeline computePipeline) {
    procs.computePipelineReference(computePipeline);
}
void wgpuComputePipelineRelease(WGPUComputePipeline computePipeline) {
    procs.computePipelineRelease(computePipeline);
}

WGPUBindGroup wgpuDeviceCreateBindGroup(WGPUDevice device, WGPUBindGroupDescriptor const * descriptor) {
return     procs.deviceCreateBindGroup(device, descriptor);
}
WGPUBindGroupLayout wgpuDeviceCreateBindGroupLayout(WGPUDevice device, WGPUBindGroupLayoutDescriptor const * descriptor) {
return     procs.deviceCreateBindGroupLayout(device, descriptor);
}
WGPUBuffer wgpuDeviceCreateBuffer(WGPUDevice device, WGPUBufferDescriptor const * descriptor) {
return     procs.deviceCreateBuffer(device, descriptor);
}
WGPUCommandEncoder wgpuDeviceCreateCommandEncoder(WGPUDevice device, WGPUCommandEncoderDescriptor const * descriptor) {
return     procs.deviceCreateCommandEncoder(device, descriptor);
}
WGPUComputePipeline wgpuDeviceCreateComputePipeline(WGPUDevice device, WGPUComputePipelineDescriptor const * descriptor) {
return     procs.deviceCreateComputePipeline(device, descriptor);
}
void wgpuDeviceCreateComputePipelineAsync(WGPUDevice device, WGPUComputePipelineDescriptor const * descriptor, WGPUCreateComputePipelineAsyncCallback callback, void * userdata) {
    procs.deviceCreateComputePipelineAsync(device, descriptor, callback, userdata);
}
WGPUBuffer wgpuDeviceCreateErrorBuffer(WGPUDevice device, WGPUBufferDescriptor const * descriptor) {
return     procs.deviceCreateErrorBuffer(device, descriptor);
}
WGPUExternalTexture wgpuDeviceCreateErrorExternalTexture(WGPUDevice device) {
return     procs.deviceCreateErrorExternalTexture(device);
}
WGPUShaderModule wgpuDeviceCreateErrorShaderModule(WGPUDevice device, WGPUShaderModuleDescriptor const * descriptor, char const * errorMessage) {
return     procs.deviceCreateErrorShaderModule(device, descriptor, errorMessage);
}
WGPUTexture wgpuDeviceCreateErrorTexture(WGPUDevice device, WGPUTextureDescriptor const * descriptor) {
return     procs.deviceCreateErrorTexture(device, descriptor);
}
WGPUExternalTexture wgpuDeviceCreateExternalTexture(WGPUDevice device, WGPUExternalTextureDescriptor const * externalTextureDescriptor) {
return     procs.deviceCreateExternalTexture(device, externalTextureDescriptor);
}
WGPUPipelineLayout wgpuDeviceCreatePipelineLayout(WGPUDevice device, WGPUPipelineLayoutDescriptor const * descriptor) {
return     procs.deviceCreatePipelineLayout(device, descriptor);
}
WGPUQuerySet wgpuDeviceCreateQuerySet(WGPUDevice device, WGPUQuerySetDescriptor const * descriptor) {
return     procs.deviceCreateQuerySet(device, descriptor);
}
WGPURenderBundleEncoder wgpuDeviceCreateRenderBundleEncoder(WGPUDevice device, WGPURenderBundleEncoderDescriptor const * descriptor) {
return     procs.deviceCreateRenderBundleEncoder(device, descriptor);
}
WGPURenderPipeline wgpuDeviceCreateRenderPipeline(WGPUDevice device, WGPURenderPipelineDescriptor const * descriptor) {
return     procs.deviceCreateRenderPipeline(device, descriptor);
}
void wgpuDeviceCreateRenderPipelineAsync(WGPUDevice device, WGPURenderPipelineDescriptor const * descriptor, WGPUCreateRenderPipelineAsyncCallback callback, void * userdata) {
    procs.deviceCreateRenderPipelineAsync(device, descriptor, callback, userdata);
}
WGPUSampler wgpuDeviceCreateSampler(WGPUDevice device, WGPUSamplerDescriptor const * descriptor) {
return     procs.deviceCreateSampler(device, descriptor);
}
WGPUShaderModule wgpuDeviceCreateShaderModule(WGPUDevice device, WGPUShaderModuleDescriptor const * descriptor) {
return     procs.deviceCreateShaderModule(device, descriptor);
}
WGPUSwapChain wgpuDeviceCreateSwapChain(WGPUDevice device, WGPUSurface surface, WGPUSwapChainDescriptor const * descriptor) {
return     procs.deviceCreateSwapChain(device, surface, descriptor);
}
WGPUTexture wgpuDeviceCreateTexture(WGPUDevice device, WGPUTextureDescriptor const * descriptor) {
return     procs.deviceCreateTexture(device, descriptor);
}
void wgpuDeviceDestroy(WGPUDevice device) {
    procs.deviceDestroy(device);
}
size_t wgpuDeviceEnumerateFeatures(WGPUDevice device, WGPUFeatureName * features) {
return     procs.deviceEnumerateFeatures(device, features);
}
void wgpuDeviceForceLoss(WGPUDevice device, WGPUDeviceLostReason type, char const * message) {
    procs.deviceForceLoss(device, type, message);
}
WGPUAdapter wgpuDeviceGetAdapter(WGPUDevice device) {
return     procs.deviceGetAdapter(device);
}
// bool wgpuDeviceGetLimits(WGPUDevice device, WGPUSupportedLimits * limits) {
// return     procs.deviceGetLimits(device, limits);
// }
WGPUQueue wgpuDeviceGetQueue(WGPUDevice device) {
return     procs.deviceGetQueue(device);
}
WGPUTextureUsageFlags wgpuDeviceGetSupportedSurfaceUsage(WGPUDevice device, WGPUSurface surface) {
return     procs.deviceGetSupportedSurfaceUsage(device, surface);
}

// bool wgpuDeviceHasFeature(WGPUDevice device, WGPUFeatureName feature) {
// return     procs.deviceHasFeature(device, feature);
// }
void wgpuDeviceInjectError(WGPUDevice device, WGPUErrorType type, char const * message) {
    procs.deviceInjectError(device, type, message);
}
void wgpuDevicePopErrorScope(WGPUDevice device, WGPUErrorCallback callback, void * userdata) {
    procs.devicePopErrorScope(device, callback, userdata);
}
void wgpuDevicePushErrorScope(WGPUDevice device, WGPUErrorFilter filter) {
    procs.devicePushErrorScope(device, filter);
}
void wgpuDeviceSetDeviceLostCallback(WGPUDevice device, WGPUDeviceLostCallback callback, void * userdata) {
    procs.deviceSetDeviceLostCallback(device, callback, userdata);
}
void wgpuDeviceSetLabel(WGPUDevice device, char const * label) {
    procs.deviceSetLabel(device, label);
}
void wgpuDeviceSetLoggingCallback(WGPUDevice device, WGPULoggingCallback callback, void * userdata) {
    procs.deviceSetLoggingCallback(device, callback, userdata);
}
void wgpuDeviceSetUncapturedErrorCallback(WGPUDevice device, WGPUErrorCallback callback, void * userdata) {
    procs.deviceSetUncapturedErrorCallback(device, callback, userdata);
}
void wgpuDeviceTick(WGPUDevice device) {
    procs.deviceTick(device);
}
void wgpuDeviceValidateTextureDescriptor(WGPUDevice device, WGPUTextureDescriptor const * descriptor) {
    procs.deviceValidateTextureDescriptor(device, descriptor);
}
void wgpuDeviceReference(WGPUDevice device) {
    procs.deviceReference(device);
}
void wgpuDeviceRelease(WGPUDevice device) {
    procs.deviceRelease(device);
}

void wgpuExternalTextureDestroy(WGPUExternalTexture externalTexture) {
    procs.externalTextureDestroy(externalTexture);
}
void wgpuExternalTextureExpire(WGPUExternalTexture externalTexture) {
    procs.externalTextureExpire(externalTexture);
}
void wgpuExternalTextureRefresh(WGPUExternalTexture externalTexture) {
    procs.externalTextureRefresh(externalTexture);
}
void wgpuExternalTextureSetLabel(WGPUExternalTexture externalTexture, char const * label) {
    procs.externalTextureSetLabel(externalTexture, label);
}
void wgpuExternalTextureReference(WGPUExternalTexture externalTexture) {
    procs.externalTextureReference(externalTexture);
}
void wgpuExternalTextureRelease(WGPUExternalTexture externalTexture) {
    procs.externalTextureRelease(externalTexture);
}

WGPUSurface wgpuInstanceCreateSurface(WGPUInstance instance, WGPUSurfaceDescriptor const * descriptor) {
return     procs.instanceCreateSurface(instance, descriptor);
}
void wgpuInstanceProcessEvents(WGPUInstance instance) {
    procs.instanceProcessEvents(instance);
}
void wgpuInstanceRequestAdapter(WGPUInstance instance, WGPURequestAdapterOptions const * options, WGPURequestAdapterCallback callback, void * userdata) {
    procs.instanceRequestAdapter(instance, options, callback, userdata);
}
void wgpuInstanceReference(WGPUInstance instance) {
    procs.instanceReference(instance);
}
void wgpuInstanceRelease(WGPUInstance instance) {
    procs.instanceRelease(instance);
}

void wgpuPipelineLayoutSetLabel(WGPUPipelineLayout pipelineLayout, char const * label) {
    procs.pipelineLayoutSetLabel(pipelineLayout, label);
}
void wgpuPipelineLayoutReference(WGPUPipelineLayout pipelineLayout) {
    procs.pipelineLayoutReference(pipelineLayout);
}
void wgpuPipelineLayoutRelease(WGPUPipelineLayout pipelineLayout) {
    procs.pipelineLayoutRelease(pipelineLayout);
}

void wgpuQuerySetDestroy(WGPUQuerySet querySet) {
    procs.querySetDestroy(querySet);
}
uint32_t wgpuQuerySetGetCount(WGPUQuerySet querySet) {
return     procs.querySetGetCount(querySet);
}
WGPUQueryType wgpuQuerySetGetType(WGPUQuerySet querySet) {
return     procs.querySetGetType(querySet);
}
void wgpuQuerySetSetLabel(WGPUQuerySet querySet, char const * label) {
    procs.querySetSetLabel(querySet, label);
}
void wgpuQuerySetReference(WGPUQuerySet querySet) {
    procs.querySetReference(querySet);
}
void wgpuQuerySetRelease(WGPUQuerySet querySet) {
    procs.querySetRelease(querySet);
}

void wgpuQueueCopyExternalTextureForBrowser(WGPUQueue queue, WGPUImageCopyExternalTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize, WGPUCopyTextureForBrowserOptions const * options) {
    procs.queueCopyExternalTextureForBrowser(queue, source, destination, copySize, options);
}
void wgpuQueueCopyTextureForBrowser(WGPUQueue queue, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize, WGPUCopyTextureForBrowserOptions const * options) {
    procs.queueCopyTextureForBrowser(queue, source, destination, copySize, options);
}
void wgpuQueueOnSubmittedWorkDone(WGPUQueue queue, uint64_t signalValue, WGPUQueueWorkDoneCallback callback, void * userdata) {
    procs.queueOnSubmittedWorkDone(queue, signalValue, callback, userdata);
}
void wgpuQueueSetLabel(WGPUQueue queue, char const * label) {
    procs.queueSetLabel(queue, label);
}
void wgpuQueueSubmit(WGPUQueue queue, size_t commandCount, WGPUCommandBuffer const * commands) {
    procs.queueSubmit(queue, commandCount, commands);
}
void wgpuQueueWriteBuffer(WGPUQueue queue, WGPUBuffer buffer, uint64_t bufferOffset, void const * data, size_t size) {
    procs.queueWriteBuffer(queue, buffer, bufferOffset, data, size);
}
void wgpuQueueWriteTexture(WGPUQueue queue, WGPUImageCopyTexture const * destination, void const * data, size_t dataSize, WGPUTextureDataLayout const * dataLayout, WGPUExtent3D const * writeSize) {
    procs.queueWriteTexture(queue, destination, data, dataSize, dataLayout, writeSize);
}
void wgpuQueueReference(WGPUQueue queue) {
    procs.queueReference(queue);
}
void wgpuQueueRelease(WGPUQueue queue) {
    procs.queueRelease(queue);
}

void wgpuRenderBundleSetLabel(WGPURenderBundle renderBundle, char const * label) {
    procs.renderBundleSetLabel(renderBundle, label);
}
void wgpuRenderBundleReference(WGPURenderBundle renderBundle) {
    procs.renderBundleReference(renderBundle);
}
void wgpuRenderBundleRelease(WGPURenderBundle renderBundle) {
    procs.renderBundleRelease(renderBundle);
}

void wgpuRenderBundleEncoderDraw(WGPURenderBundleEncoder renderBundleEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance) {
    procs.renderBundleEncoderDraw(renderBundleEncoder, vertexCount, instanceCount, firstVertex, firstInstance);
}
void wgpuRenderBundleEncoderDrawIndexed(WGPURenderBundleEncoder renderBundleEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance) {
    procs.renderBundleEncoderDrawIndexed(renderBundleEncoder, indexCount, instanceCount, firstIndex, baseVertex, firstInstance);
}
void wgpuRenderBundleEncoderDrawIndexedIndirect(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) {
    procs.renderBundleEncoderDrawIndexedIndirect(renderBundleEncoder, indirectBuffer, indirectOffset);
}
void wgpuRenderBundleEncoderDrawIndirect(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) {
    procs.renderBundleEncoderDrawIndirect(renderBundleEncoder, indirectBuffer, indirectOffset);
}
WGPURenderBundle wgpuRenderBundleEncoderFinish(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderBundleDescriptor const * descriptor) {
return     procs.renderBundleEncoderFinish(renderBundleEncoder, descriptor);
}
void wgpuRenderBundleEncoderInsertDebugMarker(WGPURenderBundleEncoder renderBundleEncoder, char const * markerLabel) {
    procs.renderBundleEncoderInsertDebugMarker(renderBundleEncoder, markerLabel);
}
void wgpuRenderBundleEncoderPopDebugGroup(WGPURenderBundleEncoder renderBundleEncoder) {
    procs.renderBundleEncoderPopDebugGroup(renderBundleEncoder);
}
void wgpuRenderBundleEncoderPushDebugGroup(WGPURenderBundleEncoder renderBundleEncoder, char const * groupLabel) {
    procs.renderBundleEncoderPushDebugGroup(renderBundleEncoder, groupLabel);
}
void wgpuRenderBundleEncoderSetBindGroup(WGPURenderBundleEncoder renderBundleEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) {
    procs.renderBundleEncoderSetBindGroup(renderBundleEncoder, groupIndex, group, dynamicOffsetCount, dynamicOffsets);
}
void wgpuRenderBundleEncoderSetIndexBuffer(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size) {
    procs.renderBundleEncoderSetIndexBuffer(renderBundleEncoder, buffer, format, offset, size);
}
void wgpuRenderBundleEncoderSetLabel(WGPURenderBundleEncoder renderBundleEncoder, char const * label) {
    procs.renderBundleEncoderSetLabel(renderBundleEncoder, label);
}
void wgpuRenderBundleEncoderSetPipeline(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderPipeline pipeline) {
    procs.renderBundleEncoderSetPipeline(renderBundleEncoder, pipeline);
}
void wgpuRenderBundleEncoderSetVertexBuffer(WGPURenderBundleEncoder renderBundleEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size) {
    procs.renderBundleEncoderSetVertexBuffer(renderBundleEncoder, slot, buffer, offset, size);
}
void wgpuRenderBundleEncoderReference(WGPURenderBundleEncoder renderBundleEncoder) {
    procs.renderBundleEncoderReference(renderBundleEncoder);
}
void wgpuRenderBundleEncoderRelease(WGPURenderBundleEncoder renderBundleEncoder) {
    procs.renderBundleEncoderRelease(renderBundleEncoder);
}

void wgpuRenderPassEncoderBeginOcclusionQuery(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex) {
    procs.renderPassEncoderBeginOcclusionQuery(renderPassEncoder, queryIndex);
}
void wgpuRenderPassEncoderDraw(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance) {
    procs.renderPassEncoderDraw(renderPassEncoder, vertexCount, instanceCount, firstVertex, firstInstance);
}
void wgpuRenderPassEncoderDrawIndexed(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance) {
    procs.renderPassEncoderDrawIndexed(renderPassEncoder, indexCount, instanceCount, firstIndex, baseVertex, firstInstance);
}
void wgpuRenderPassEncoderDrawIndexedIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) {
    procs.renderPassEncoderDrawIndexedIndirect(renderPassEncoder, indirectBuffer, indirectOffset);
}
void wgpuRenderPassEncoderDrawIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) {
    procs.renderPassEncoderDrawIndirect(renderPassEncoder, indirectBuffer, indirectOffset);
}
void wgpuRenderPassEncoderEnd(WGPURenderPassEncoder renderPassEncoder) {
    procs.renderPassEncoderEnd(renderPassEncoder);
}
void wgpuRenderPassEncoderEndOcclusionQuery(WGPURenderPassEncoder renderPassEncoder) {
    procs.renderPassEncoderEndOcclusionQuery(renderPassEncoder);
}
void wgpuRenderPassEncoderExecuteBundles(WGPURenderPassEncoder renderPassEncoder, size_t bundleCount, WGPURenderBundle const * bundles) {
    procs.renderPassEncoderExecuteBundles(renderPassEncoder, bundleCount, bundles);
}
void wgpuRenderPassEncoderInsertDebugMarker(WGPURenderPassEncoder renderPassEncoder, char const * markerLabel) {
    procs.renderPassEncoderInsertDebugMarker(renderPassEncoder, markerLabel);
}
void wgpuRenderPassEncoderPopDebugGroup(WGPURenderPassEncoder renderPassEncoder) {
    procs.renderPassEncoderPopDebugGroup(renderPassEncoder);
}
void wgpuRenderPassEncoderPushDebugGroup(WGPURenderPassEncoder renderPassEncoder, char const * groupLabel) {
    procs.renderPassEncoderPushDebugGroup(renderPassEncoder, groupLabel);
}
void wgpuRenderPassEncoderSetBindGroup(WGPURenderPassEncoder renderPassEncoder, uint32_t groupIndex, WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) {
    procs.renderPassEncoderSetBindGroup(renderPassEncoder, groupIndex, group, dynamicOffsetCount, dynamicOffsets);
}
void wgpuRenderPassEncoderSetBlendConstant(WGPURenderPassEncoder renderPassEncoder, WGPUColor const * color) {
    procs.renderPassEncoderSetBlendConstant(renderPassEncoder, color);
}
void wgpuRenderPassEncoderSetIndexBuffer(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size) {
    procs.renderPassEncoderSetIndexBuffer(renderPassEncoder, buffer, format, offset, size);
}
void wgpuRenderPassEncoderSetLabel(WGPURenderPassEncoder renderPassEncoder, char const * label) {
    procs.renderPassEncoderSetLabel(renderPassEncoder, label);
}
void wgpuRenderPassEncoderSetPipeline(WGPURenderPassEncoder renderPassEncoder, WGPURenderPipeline pipeline) {
    procs.renderPassEncoderSetPipeline(renderPassEncoder, pipeline);
}
void wgpuRenderPassEncoderSetScissorRect(WGPURenderPassEncoder renderPassEncoder, uint32_t x, uint32_t y, uint32_t width, uint32_t height) {
    procs.renderPassEncoderSetScissorRect(renderPassEncoder, x, y, width, height);
}
void wgpuRenderPassEncoderSetStencilReference(WGPURenderPassEncoder renderPassEncoder, uint32_t reference) {
    procs.renderPassEncoderSetStencilReference(renderPassEncoder, reference);
}
void wgpuRenderPassEncoderSetVertexBuffer(WGPURenderPassEncoder renderPassEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size) {
    procs.renderPassEncoderSetVertexBuffer(renderPassEncoder, slot, buffer, offset, size);
}
void wgpuRenderPassEncoderSetViewport(WGPURenderPassEncoder renderPassEncoder, float x, float y, float width, float height, float minDepth, float maxDepth) {
    procs.renderPassEncoderSetViewport(renderPassEncoder, x, y, width, height, minDepth, maxDepth);
}
void wgpuRenderPassEncoderWriteTimestamp(WGPURenderPassEncoder renderPassEncoder, WGPUQuerySet querySet, uint32_t queryIndex) {
    procs.renderPassEncoderWriteTimestamp(renderPassEncoder, querySet, queryIndex);
}
void wgpuRenderPassEncoderReference(WGPURenderPassEncoder renderPassEncoder) {
    procs.renderPassEncoderReference(renderPassEncoder);
}
void wgpuRenderPassEncoderRelease(WGPURenderPassEncoder renderPassEncoder) {
    procs.renderPassEncoderRelease(renderPassEncoder);
}

WGPUBindGroupLayout wgpuRenderPipelineGetBindGroupLayout(WGPURenderPipeline renderPipeline, uint32_t groupIndex) {
return     procs.renderPipelineGetBindGroupLayout(renderPipeline, groupIndex);
}
void wgpuRenderPipelineSetLabel(WGPURenderPipeline renderPipeline, char const * label) {
    procs.renderPipelineSetLabel(renderPipeline, label);
}
void wgpuRenderPipelineReference(WGPURenderPipeline renderPipeline) {
    procs.renderPipelineReference(renderPipeline);
}
void wgpuRenderPipelineRelease(WGPURenderPipeline renderPipeline) {
    procs.renderPipelineRelease(renderPipeline);
}

void wgpuSamplerSetLabel(WGPUSampler sampler, char const * label) {
    procs.samplerSetLabel(sampler, label);
}
void wgpuSamplerReference(WGPUSampler sampler) {
    procs.samplerReference(sampler);
}
void wgpuSamplerRelease(WGPUSampler sampler) {
    procs.samplerRelease(sampler);
}

void wgpuShaderModuleGetCompilationInfo(WGPUShaderModule shaderModule, WGPUCompilationInfoCallback callback, void * userdata) {
    procs.shaderModuleGetCompilationInfo(shaderModule, callback, userdata);
}
void wgpuShaderModuleSetLabel(WGPUShaderModule shaderModule, char const * label) {
    procs.shaderModuleSetLabel(shaderModule, label);
}
void wgpuShaderModuleReference(WGPUShaderModule shaderModule) {
    procs.shaderModuleReference(shaderModule);
}
void wgpuShaderModuleRelease(WGPUShaderModule shaderModule) {
    procs.shaderModuleRelease(shaderModule);
}

void wgpuSurfaceReference(WGPUSurface surface) {
    procs.surfaceReference(surface);
}
void wgpuSurfaceRelease(WGPUSurface surface) {
    procs.surfaceRelease(surface);
}

WGPUTexture wgpuSwapChainGetCurrentTexture(WGPUSwapChain swapChain) {
return     procs.swapChainGetCurrentTexture(swapChain);
}
WGPUTextureView wgpuSwapChainGetCurrentTextureView(WGPUSwapChain swapChain) {
return     procs.swapChainGetCurrentTextureView(swapChain);
}
void wgpuSwapChainPresent(WGPUSwapChain swapChain) {
    procs.swapChainPresent(swapChain);
}
void wgpuSwapChainReference(WGPUSwapChain swapChain) {
    procs.swapChainReference(swapChain);
}
void wgpuSwapChainRelease(WGPUSwapChain swapChain) {
    procs.swapChainRelease(swapChain);
}

WGPUTextureView wgpuTextureCreateView(WGPUTexture texture, WGPUTextureViewDescriptor const * descriptor) {
return     procs.textureCreateView(texture, descriptor);
}
void wgpuTextureDestroy(WGPUTexture texture) {
    procs.textureDestroy(texture);
}
uint32_t wgpuTextureGetDepthOrArrayLayers(WGPUTexture texture) {
return     procs.textureGetDepthOrArrayLayers(texture);
}
WGPUTextureDimension wgpuTextureGetDimension(WGPUTexture texture) {
return     procs.textureGetDimension(texture);
}
WGPUTextureFormat wgpuTextureGetFormat(WGPUTexture texture) {
return     procs.textureGetFormat(texture);
}
uint32_t wgpuTextureGetHeight(WGPUTexture texture) {
return     procs.textureGetHeight(texture);
}
uint32_t wgpuTextureGetMipLevelCount(WGPUTexture texture) {
return     procs.textureGetMipLevelCount(texture);
}
uint32_t wgpuTextureGetSampleCount(WGPUTexture texture) {
return     procs.textureGetSampleCount(texture);
}
WGPUTextureUsageFlags wgpuTextureGetUsage(WGPUTexture texture) {
return     procs.textureGetUsage(texture);
}
uint32_t wgpuTextureGetWidth(WGPUTexture texture) {
return     procs.textureGetWidth(texture);
}
void wgpuTextureSetLabel(WGPUTexture texture, char const * label) {
    procs.textureSetLabel(texture, label);
}
void wgpuTextureReference(WGPUTexture texture) {
    procs.textureReference(texture);
}
void wgpuTextureRelease(WGPUTexture texture) {
    procs.textureRelease(texture);
}

void wgpuTextureViewSetLabel(WGPUTextureView textureView, char const * label) {
    procs.textureViewSetLabel(textureView, label);
}
void wgpuTextureViewReference(WGPUTextureView textureView) {
    procs.textureViewReference(textureView);
}
void wgpuTextureViewRelease(WGPUTextureView textureView) {
    procs.textureViewRelease(textureView);
}

// WGPU_EXPORT void wgpuAdapterPropertiesFreeMembers(WGPUAdapterProperties value) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUInstance wgpuCreateInstance(WGPUInstanceDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUProc wgpuGetProcAddress(WGPUDevice device, char const * procName) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemoryEndAccessStateFreeMembers(WGPUSharedTextureMemoryEndAccessState value) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Adapter
// WGPU_EXPORT WGPUDevice wgpuAdapterCreateDevice(WGPUAdapter adapter, WGPU_NULLABLE WGPUDeviceDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT size_t wgpuAdapterEnumerateFeatures(WGPUAdapter adapter, WGPUFeatureName * features) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUInstance wgpuAdapterGetInstance(WGPUAdapter adapter) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBool wgpuAdapterGetLimits(WGPUAdapter adapter, WGPUSupportedLimits * limits) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuAdapterGetProperties(WGPUAdapter adapter, WGPUAdapterProperties * properties) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBool wgpuAdapterHasFeature(WGPUAdapter adapter, WGPUFeatureName feature) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuAdapterRequestDevice(WGPUAdapter adapter, WGPU_NULLABLE WGPUDeviceDescriptor const * descriptor, WGPURequestDeviceCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuAdapterReference(WGPUAdapter adapter) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuAdapterRelease(WGPUAdapter adapter) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of BindGroup
// WGPU_EXPORT void wgpuBindGroupSetLabel(WGPUBindGroup bindGroup, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBindGroupReference(WGPUBindGroup bindGroup) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBindGroupRelease(WGPUBindGroup bindGroup) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of BindGroupLayout
// WGPU_EXPORT void wgpuBindGroupLayoutSetLabel(WGPUBindGroupLayout bindGroupLayout, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBindGroupLayoutReference(WGPUBindGroupLayout bindGroupLayout) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBindGroupLayoutRelease(WGPUBindGroupLayout bindGroupLayout) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Buffer
// WGPU_EXPORT void wgpuBufferDestroy(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void const * wgpuBufferGetConstMappedRange(WGPUBuffer buffer, size_t offset, size_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBufferMapState wgpuBufferGetMapState(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void * wgpuBufferGetMappedRange(WGPUBuffer buffer, size_t offset, size_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint64_t wgpuBufferGetSize(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBufferUsageFlags wgpuBufferGetUsage(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBufferMapAsync(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBufferSetLabel(WGPUBuffer buffer, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBufferUnmap(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBufferReference(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuBufferRelease(WGPUBuffer buffer) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of CommandBuffer
// WGPU_EXPORT void wgpuCommandBufferSetLabel(WGPUCommandBuffer commandBuffer, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandBufferReference(WGPUCommandBuffer commandBuffer) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandBufferRelease(WGPUCommandBuffer commandBuffer) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of CommandEncoder
// WGPU_EXPORT WGPUComputePassEncoder wgpuCommandEncoderBeginComputePass(WGPUCommandEncoder commandEncoder, WGPU_NULLABLE WGPUComputePassDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPURenderPassEncoder wgpuCommandEncoderBeginRenderPass(WGPUCommandEncoder commandEncoder, WGPURenderPassDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderClearBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderCopyBufferToBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderCopyBufferToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderCopyTextureToBuffer(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyBuffer const * destination, WGPUExtent3D const * copySize) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderCopyTextureToTexture(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUCommandBuffer wgpuCommandEncoderFinish(WGPUCommandEncoder commandEncoder, WGPU_NULLABLE WGPUCommandBufferDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderInjectValidationError(WGPUCommandEncoder commandEncoder, char const * message) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderInsertDebugMarker(WGPUCommandEncoder commandEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderPopDebugGroup(WGPUCommandEncoder commandEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderPushDebugGroup(WGPUCommandEncoder commandEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderResolveQuerySet(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderSetLabel(WGPUCommandEncoder commandEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderWriteBuffer(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t bufferOffset, uint8_t const * data, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderWriteTimestamp(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderReference(WGPUCommandEncoder commandEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuCommandEncoderRelease(WGPUCommandEncoder commandEncoder) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of ComputePassEncoder
// WGPU_EXPORT void wgpuComputePassEncoderDispatchWorkgroups(WGPUComputePassEncoder computePassEncoder, uint32_t workgroupCountX, uint32_t workgroupCountY, uint32_t workgroupCountZ) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderDispatchWorkgroupsIndirect(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderEnd(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderInsertDebugMarker(WGPUComputePassEncoder computePassEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderPopDebugGroup(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderPushDebugGroup(WGPUComputePassEncoder computePassEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderSetBindGroup(WGPUComputePassEncoder computePassEncoder, uint32_t groupIndex, WGPU_NULLABLE WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderSetLabel(WGPUComputePassEncoder computePassEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderSetPipeline(WGPUComputePassEncoder computePassEncoder, WGPUComputePipeline pipeline) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderWriteTimestamp(WGPUComputePassEncoder computePassEncoder, WGPUQuerySet querySet, uint32_t queryIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderReference(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePassEncoderRelease(WGPUComputePassEncoder computePassEncoder) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of ComputePipeline
// WGPU_EXPORT WGPUBindGroupLayout wgpuComputePipelineGetBindGroupLayout(WGPUComputePipeline computePipeline, uint32_t groupIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePipelineSetLabel(WGPUComputePipeline computePipeline, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePipelineReference(WGPUComputePipeline computePipeline) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuComputePipelineRelease(WGPUComputePipeline computePipeline) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Device
// WGPU_EXPORT WGPUBindGroup wgpuDeviceCreateBindGroup(WGPUDevice device, WGPUBindGroupDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBindGroupLayout wgpuDeviceCreateBindGroupLayout(WGPUDevice device, WGPUBindGroupLayoutDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBuffer wgpuDeviceCreateBuffer(WGPUDevice device, WGPUBufferDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUCommandEncoder wgpuDeviceCreateCommandEncoder(WGPUDevice device, WGPU_NULLABLE WGPUCommandEncoderDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUComputePipeline wgpuDeviceCreateComputePipeline(WGPUDevice device, WGPUComputePipelineDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceCreateComputePipelineAsync(WGPUDevice device, WGPUComputePipelineDescriptor const * descriptor, WGPUCreateComputePipelineAsyncCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBuffer wgpuDeviceCreateErrorBuffer(WGPUDevice device, WGPUBufferDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUExternalTexture wgpuDeviceCreateErrorExternalTexture(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUShaderModule wgpuDeviceCreateErrorShaderModule(WGPUDevice device, WGPUShaderModuleDescriptor const * descriptor, char const * errorMessage) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTexture wgpuDeviceCreateErrorTexture(WGPUDevice device, WGPUTextureDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUExternalTexture wgpuDeviceCreateExternalTexture(WGPUDevice device, WGPUExternalTextureDescriptor const * externalTextureDescriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUPipelineLayout wgpuDeviceCreatePipelineLayout(WGPUDevice device, WGPUPipelineLayoutDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUQuerySet wgpuDeviceCreateQuerySet(WGPUDevice device, WGPUQuerySetDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPURenderBundleEncoder wgpuDeviceCreateRenderBundleEncoder(WGPUDevice device, WGPURenderBundleEncoderDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPURenderPipeline wgpuDeviceCreateRenderPipeline(WGPUDevice device, WGPURenderPipelineDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceCreateRenderPipelineAsync(WGPUDevice device, WGPURenderPipelineDescriptor const * descriptor, WGPUCreateRenderPipelineAsyncCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUSampler wgpuDeviceCreateSampler(WGPUDevice device, WGPU_NULLABLE WGPUSamplerDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUShaderModule wgpuDeviceCreateShaderModule(WGPUDevice device, WGPUShaderModuleDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUSwapChain wgpuDeviceCreateSwapChain(WGPUDevice device, WGPUSurface surface, WGPUSwapChainDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTexture wgpuDeviceCreateTexture(WGPUDevice device, WGPUTextureDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceDestroy(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT size_t wgpuDeviceEnumerateFeatures(WGPUDevice device, WGPUFeatureName * features) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceForceLoss(WGPUDevice device, WGPUDeviceLostReason type, char const * message) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUAdapter wgpuDeviceGetAdapter(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBool wgpuDeviceGetLimits(WGPUDevice device, WGPUSupportedLimits * limits) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUQueue wgpuDeviceGetQueue(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTextureUsageFlags wgpuDeviceGetSupportedSurfaceUsage(WGPUDevice device, WGPUSurface surface) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUBool wgpuDeviceHasFeature(WGPUDevice device, WGPUFeatureName feature) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUSharedFence wgpuDeviceImportSharedFence(WGPUDevice device, WGPUSharedFenceDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUSharedTextureMemory wgpuDeviceImportSharedTextureMemory(WGPUDevice device, WGPUSharedTextureMemoryDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceInjectError(WGPUDevice device, WGPUErrorType type, char const * message) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDevicePopErrorScope(WGPUDevice device, WGPUErrorCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDevicePushErrorScope(WGPUDevice device, WGPUErrorFilter filter) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceSetDeviceLostCallback(WGPUDevice device, WGPUDeviceLostCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceSetLabel(WGPUDevice device, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceSetLoggingCallback(WGPUDevice device, WGPULoggingCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceSetUncapturedErrorCallback(WGPUDevice device, WGPUErrorCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceTick(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceValidateTextureDescriptor(WGPUDevice device, WGPUTextureDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceReference(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuDeviceRelease(WGPUDevice device) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of ExternalTexture
// WGPU_EXPORT void wgpuExternalTextureDestroy(WGPUExternalTexture externalTexture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuExternalTextureExpire(WGPUExternalTexture externalTexture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuExternalTextureRefresh(WGPUExternalTexture externalTexture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuExternalTextureSetLabel(WGPUExternalTexture externalTexture, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuExternalTextureReference(WGPUExternalTexture externalTexture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuExternalTextureRelease(WGPUExternalTexture externalTexture) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Instance
// WGPU_EXPORT WGPUSurface wgpuInstanceCreateSurface(WGPUInstance instance, WGPUSurfaceDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuInstanceProcessEvents(WGPUInstance instance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuInstanceRequestAdapter(WGPUInstance instance, WGPU_NULLABLE WGPURequestAdapterOptions const * options, WGPURequestAdapterCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuInstanceReference(WGPUInstance instance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuInstanceRelease(WGPUInstance instance) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of PipelineLayout
// WGPU_EXPORT void wgpuPipelineLayoutSetLabel(WGPUPipelineLayout pipelineLayout, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuPipelineLayoutReference(WGPUPipelineLayout pipelineLayout) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuPipelineLayoutRelease(WGPUPipelineLayout pipelineLayout) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of QuerySet
// WGPU_EXPORT void wgpuQuerySetDestroy(WGPUQuerySet querySet) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuQuerySetGetCount(WGPUQuerySet querySet) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUQueryType wgpuQuerySetGetType(WGPUQuerySet querySet) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQuerySetSetLabel(WGPUQuerySet querySet, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQuerySetReference(WGPUQuerySet querySet) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQuerySetRelease(WGPUQuerySet querySet) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Queue
// WGPU_EXPORT void wgpuQueueCopyExternalTextureForBrowser(WGPUQueue queue, WGPUImageCopyExternalTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize, WGPUCopyTextureForBrowserOptions const * options) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueCopyTextureForBrowser(WGPUQueue queue, WGPUImageCopyTexture const * source, WGPUImageCopyTexture const * destination, WGPUExtent3D const * copySize, WGPUCopyTextureForBrowserOptions const * options) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueOnSubmittedWorkDone(WGPUQueue queue, uint64_t signalValue, WGPUQueueWorkDoneCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueSetLabel(WGPUQueue queue, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueSubmit(WGPUQueue queue, size_t commandCount, WGPUCommandBuffer const * commands) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueWriteBuffer(WGPUQueue queue, WGPUBuffer buffer, uint64_t bufferOffset, void const * data, size_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueWriteTexture(WGPUQueue queue, WGPUImageCopyTexture const * destination, void const * data, size_t dataSize, WGPUTextureDataLayout const * dataLayout, WGPUExtent3D const * writeSize) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueReference(WGPUQueue queue) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuQueueRelease(WGPUQueue queue) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of RenderBundle
// WGPU_EXPORT void wgpuRenderBundleSetLabel(WGPURenderBundle renderBundle, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleReference(WGPURenderBundle renderBundle) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleRelease(WGPURenderBundle renderBundle) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of RenderBundleEncoder
// WGPU_EXPORT void wgpuRenderBundleEncoderDraw(WGPURenderBundleEncoder renderBundleEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderDrawIndexed(WGPURenderBundleEncoder renderBundleEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderDrawIndexedIndirect(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderDrawIndirect(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPURenderBundle wgpuRenderBundleEncoderFinish(WGPURenderBundleEncoder renderBundleEncoder, WGPU_NULLABLE WGPURenderBundleDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderInsertDebugMarker(WGPURenderBundleEncoder renderBundleEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderPopDebugGroup(WGPURenderBundleEncoder renderBundleEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderPushDebugGroup(WGPURenderBundleEncoder renderBundleEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderSetBindGroup(WGPURenderBundleEncoder renderBundleEncoder, uint32_t groupIndex, WGPU_NULLABLE WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderSetIndexBuffer(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderSetLabel(WGPURenderBundleEncoder renderBundleEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderSetPipeline(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderPipeline pipeline) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderSetVertexBuffer(WGPURenderBundleEncoder renderBundleEncoder, uint32_t slot, WGPU_NULLABLE WGPUBuffer buffer, uint64_t offset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderReference(WGPURenderBundleEncoder renderBundleEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderBundleEncoderRelease(WGPURenderBundleEncoder renderBundleEncoder) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of RenderPassEncoder
// WGPU_EXPORT void wgpuRenderPassEncoderBeginOcclusionQuery(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderDraw(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexed(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderDrawIndexedIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderDrawIndirect(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderEnd(WGPURenderPassEncoder renderPassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderEndOcclusionQuery(WGPURenderPassEncoder renderPassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderExecuteBundles(WGPURenderPassEncoder renderPassEncoder, size_t bundleCount, WGPURenderBundle const * bundles) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderInsertDebugMarker(WGPURenderPassEncoder renderPassEncoder, char const * markerLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderPopDebugGroup(WGPURenderPassEncoder renderPassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderPushDebugGroup(WGPURenderPassEncoder renderPassEncoder, char const * groupLabel) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetBindGroup(WGPURenderPassEncoder renderPassEncoder, uint32_t groupIndex, WGPU_NULLABLE WGPUBindGroup group, size_t dynamicOffsetCount, uint32_t const * dynamicOffsets) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetBlendConstant(WGPURenderPassEncoder renderPassEncoder, WGPUColor const * color) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetIndexBuffer(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetLabel(WGPURenderPassEncoder renderPassEncoder, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetPipeline(WGPURenderPassEncoder renderPassEncoder, WGPURenderPipeline pipeline) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetScissorRect(WGPURenderPassEncoder renderPassEncoder, uint32_t x, uint32_t y, uint32_t width, uint32_t height) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetStencilReference(WGPURenderPassEncoder renderPassEncoder, uint32_t reference) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetVertexBuffer(WGPURenderPassEncoder renderPassEncoder, uint32_t slot, WGPU_NULLABLE WGPUBuffer buffer, uint64_t offset, uint64_t size) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderSetViewport(WGPURenderPassEncoder renderPassEncoder, float x, float y, float width, float height, float minDepth, float maxDepth) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderWriteTimestamp(WGPURenderPassEncoder renderPassEncoder, WGPUQuerySet querySet, uint32_t queryIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderReference(WGPURenderPassEncoder renderPassEncoder) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPassEncoderRelease(WGPURenderPassEncoder renderPassEncoder) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of RenderPipeline
// WGPU_EXPORT WGPUBindGroupLayout wgpuRenderPipelineGetBindGroupLayout(WGPURenderPipeline renderPipeline, uint32_t groupIndex) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPipelineSetLabel(WGPURenderPipeline renderPipeline, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPipelineReference(WGPURenderPipeline renderPipeline) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuRenderPipelineRelease(WGPURenderPipeline renderPipeline) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Sampler
// WGPU_EXPORT void wgpuSamplerSetLabel(WGPUSampler sampler, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSamplerReference(WGPUSampler sampler) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSamplerRelease(WGPUSampler sampler) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of ShaderModule
// WGPU_EXPORT void wgpuShaderModuleGetCompilationInfo(WGPUShaderModule shaderModule, WGPUCompilationInfoCallback callback, void * userdata) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuShaderModuleSetLabel(WGPUShaderModule shaderModule, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuShaderModuleReference(WGPUShaderModule shaderModule) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuShaderModuleRelease(WGPUShaderModule shaderModule) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of SharedFence
// WGPU_EXPORT void wgpuSharedFenceExportInfo(WGPUSharedFence sharedFence, WGPUSharedFenceExportInfo * info) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedFenceReference(WGPUSharedFence sharedFence) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedFenceRelease(WGPUSharedFence sharedFence) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of SharedTextureMemory
// WGPU_EXPORT void wgpuSharedTextureMemoryBeginAccess(WGPUSharedTextureMemory sharedTextureMemory, WGPUTexture texture, WGPUSharedTextureMemoryBeginAccessDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTexture wgpuSharedTextureMemoryCreateTexture(WGPUSharedTextureMemory sharedTextureMemory, WGPUTextureDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemoryEndAccess(WGPUSharedTextureMemory sharedTextureMemory, WGPUTexture texture, WGPUSharedTextureMemoryEndAccessState * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemoryGetProperties(WGPUSharedTextureMemory sharedTextureMemory, WGPUSharedTextureMemoryProperties * properties) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemorySetLabel(WGPUSharedTextureMemory sharedTextureMemory, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemoryReference(WGPUSharedTextureMemory sharedTextureMemory) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSharedTextureMemoryRelease(WGPUSharedTextureMemory sharedTextureMemory) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Surface
// WGPU_EXPORT void wgpuSurfaceReference(WGPUSurface surface) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSurfaceRelease(WGPUSurface surface) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of SwapChain
// WGPU_EXPORT WGPUTexture wgpuSwapChainGetCurrentTexture(WGPUSwapChain swapChain) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTextureView wgpuSwapChainGetCurrentTextureView(WGPUSwapChain swapChain) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSwapChainPresent(WGPUSwapChain swapChain) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSwapChainReference(WGPUSwapChain swapChain) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuSwapChainRelease(WGPUSwapChain swapChain) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of Texture
// WGPU_EXPORT WGPUTextureView wgpuTextureCreateView(WGPUTexture texture, WGPU_NULLABLE WGPUTextureViewDescriptor const * descriptor) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureDestroy(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuTextureGetDepthOrArrayLayers(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTextureDimension wgpuTextureGetDimension(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTextureFormat wgpuTextureGetFormat(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuTextureGetHeight(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuTextureGetMipLevelCount(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuTextureGetSampleCount(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT WGPUTextureUsageFlags wgpuTextureGetUsage(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT uint32_t wgpuTextureGetWidth(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureSetLabel(WGPUTexture texture, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureReference(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureRelease(WGPUTexture texture) WGPU_FUNCTION_ATTRIBUTE;

// // Methods of TextureView
// WGPU_EXPORT void wgpuTextureViewSetLabel(WGPUTextureView textureView, char const * label) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureViewReference(WGPUTextureView textureView) WGPU_FUNCTION_ATTRIBUTE;
// WGPU_EXPORT void wgpuTextureViewRelease(WGPUTextureView textureView) WGPU_FUNCTION_ATTRIBUTE;