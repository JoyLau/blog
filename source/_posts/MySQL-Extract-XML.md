---
title: MySQL 解析 XML 文件
date: 2023-07-27 09:40:54
description: MySQL 解析 XML 文件
categories: [MySQL篇]
tags: [MySQL]
---
<!-- more -->

## 语法
XML 示例

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<definitions xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:camunda="http://camunda.org/schema/1.0/bpmn" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" id="definitions_a563b995-6727-44a6-b7c9-613f54d9145c" targetNamespace="1" xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL">
  <process id="process_SBJY" isExecutable="true" name="设备借用">
    <documentation id="documentation_6f4c7594-bfd9-4b51-8477-a8165c33ca19">{"setting":{"name":"设备借用","categoryId":1,"desc":"","repeatType":0,"autoPass":true,"enableUndo":true,"enableTransfer":true,"enableAuth":true,"id":"process_SBJY:24:c5e034aa-253a-11ee-b160-1aa02d19e831"},"form":[{"title":"单行输入框","type":"单行输入框","name":"TextInput","icon":"icon-danhangwenben","value":"","valueType":"String","props":{"placeholder":"请输入","required":false,"mobileShow":false,"pcShow":true},"id":"field3251030156446","err":false},{"title":"视频","type":"视频","name":"VideoUpload","icon":"icon-shipin","value":[],"valueType":"Array","props":{"required":false,"hiddenMobileShow":true,"maxSize":200,"maxNumber":1,"enableZip":true},"id":"field5186540608388","isInTable":false,"err":false},{"title":"数字","type":"数字","name":"NumberInput","icon":"icon-shuzi","value":null,"valueType":"Number","props":{"placeholder":"请输入","required":true,"mobileShow":true,"pcShow":true},"id":"field2918600070275","isInTable":false,"err":false},{"title":"人员","type":"人员","name":"UserPicker","icon":"icon-renyuan","value":[],"valueType":"User","props":{"placeholder":"请选择人员","required":true,"mobileShow":true,"pcShow":true,"multiple":true},"id":"field2758549148097","isInTable":false,"err":false},{"title":"部门","type":"部门","name":"DeptPicker","icon":"icon-bumen","value":[],"valueType":"Dept","props":{"placeholder":"请选择部门","required":true,"mobileShow":false,"pcShow":true},"id":"field3836364467190","isInTable":false,"err":false}],"process":{"id":"root","parentId":null,"type":"ROOT","name":"发起人","desc":"任何人","props":{"assignedUser":[],"formPerms":[]},"children":{"id":"node_616935911517","parentId":"root","props":{"assignedType":["ASSIGN_USER"],"mode":"AND","sign":false,"nobody":{"handler":"TO_PASS","assignedUser":[]},"assignedUser":[{"id":"1585090515499008001","name":"蜀山分局","orgName":null,"type":2,"number":2,"photo":null},{"id":"1585090627415621634","name":"蜀山分局2","orgName":null,"type":2,"number":5,"photo":null},{"id":"1585109286318030850","name":"地方监狱-ch","orgName":null,"type":2,"number":3,"photo":null},{"id":"1602586682327564289","name":"11112342","orgName":null,"type":2,"number":3,"photo":null},{"id":"1635892057621479425","name":"狱政科","orgName":null,"type":2,"number":4,"photo":null},{"id":"1578658896143728642","name":"科室1","orgName":null,"type":2,"number":8,"photo":null},{"id":"1625451599632105474","name":"分分分","orgName":null,"type":2,"number":2,"photo":null},{"id":"1572024105919086593","name":"001","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1574934048770945026","name":"ch","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1579683243000184834","name":"90","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1580726129128992770","name":"186-超级管理员","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582182526693732354","name":"测试1","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582267287462277121","name":"李聪","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268293298319361","name":"张爱婷","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268293659029506","name":"李聪","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268294598553601","name":"李聪婷","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268295139618817","name":"张婷聪","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268295470968833","name":"张婷","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268295823290369","name":"张爱聪","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268296012034050","name":"任婷","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582268296188194818","name":"张婷聪","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1582938632181313538","name":"李婷","orgName":"省局","type":1,"number":null,"photo":""}],"roleOrg":{"role":[],"roleOrgType":"","org":[]}},"type":"CC","name":"抄送人","children":{"id":"node_926398936983","parentId":"node_616935911517","props":{"assignedType":["ASSIGN_USER"],"mode":"NEXT","sign":false,"nobody":{"handler":"TO_EXCEPTIONAL","assignedUser":[]},"assignedUser":[{"id":"1580726129128992770","name":"186-超级管理员","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1659398930563702785","name":"刘法手机","orgName":"科室1","type":1,"number":null,"photo":"168673478113543988cbfefe15f74157569bb3107d652"},{"id":"1585094725347098626","name":"11111","orgName":null,"type":2,"number":0,"photo":null}],"roleOrg":{"role":[],"roleOrgType":"ALL","org":[]}},"type":"APPROVAL","name":"审批人","children":{"id":"node_839328175114","parentId":"node_926398936983","props":{"assignedType":["ASSIGN_USER"],"mode":"OR","sign":false,"nobody":{"handler":"TO_PASS","assignedUser":[]},"assignedUser":[{"id":"1580726129128992770","name":"186-超级管理员","orgName":"省局","type":1,"number":null,"photo":""},{"id":"1659398930563702785","name":"刘法手机","orgName":"科室1","type":1,"number":null,"photo":""},{"id":"1572769134128214018","name":"张柱11","orgName":"科室1","type":1,"number":null,"photo":"1684823575798a655866a187cf9c8d995b8dae79fb77a"},{"id":"1613445750961299458","name":"洪小霞","orgName":"科室1","type":1,"number":null,"photo":""}],"roleOrg":{"role":[],"roleOrgType":"","org":[]}},"type":"APPROVAL","name":"审批人","children":{}}}}}}</documentation>
    <extensionElements>
      <camunda:properties>
        <camunda:property name="createBy" value="1580726129128992770"/>
        <camunda:property name="createAt" value="2023-07-19T17:56:37.413"/>
      </camunda:properties>
    </extensionElements>
    <startEvent id="root" name="发起人">
      <documentation id="documentation_3c5043d1-e67d-45df-bfe3-89abc6b1f1ba">{"assignedUser":[],"formPerms":[]}</documentation>
      <extensionElements>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.start.StartEventStartListener" event="start"/>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.start.StartEventEndListener" event="end"/>
      </extensionElements>
      <outgoing>sequenceFlow_76b564f1-d4ad-4d53-900e-947df8979783</outgoing>
    </startEvent>
    <sendTask camunda:class="com.hfky.workflow.server.module.camunda.delegate.CCTaskDelegate" id="node_616935911517" name="抄送人">
      <documentation id="documentation_bf70d26d-f7fe-4547-b27b-142ab7c9b613">{"assignedType":["ASSIGN_USER"],"assignedUser":[{"id":"1585090515499008001","name":"蜀山分局","type":2},{"id":"1585090627415621634","name":"蜀山分局2","type":2},{"id":"1585109286318030850","name":"地方监狱-ch","type":2},{"id":"1602586682327564289","name":"11112342","type":2},{"id":"1635892057621479425","name":"狱政科","type":2},{"id":"1578658896143728642","name":"科室1","type":2},{"id":"1625451599632105474","name":"分分分","type":2},{"id":"1572024105919086593","name":"001","type":1},{"id":"1574934048770945026","name":"ch","type":1},{"id":"1579683243000184834","name":"90","type":1},{"id":"1580726129128992770","name":"186-超级管理员","type":1},{"id":"1582182526693732354","name":"测试1","type":1},{"id":"1582267287462277121","name":"李聪","type":1},{"id":"1582268293298319361","name":"张爱婷","type":1},{"id":"1582268293659029506","name":"李聪","type":1},{"id":"1582268294598553601","name":"李聪婷","type":1},{"id":"1582268295139618817","name":"张婷聪","type":1},{"id":"1582268295470968833","name":"张婷","type":1},{"id":"1582268295823290369","name":"张爱聪","type":1},{"id":"1582268296012034050","name":"任婷","type":1},{"id":"1582268296188194818","name":"张婷聪","type":1},{"id":"1582938632181313538","name":"李婷","type":1}],"roleOrg":{"role":[],"roleOrgType":"UNKNOWN","org":[]},"selfSelect":null,"formUser":null}</documentation>
      <extensionElements>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.task.sendtask.start.SendTaskStartListener" event="start"/>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.task.sendtask.end.SendTaskEndListener" event="end"/>
      </extensionElements>
      <incoming>sequenceFlow_76b564f1-d4ad-4d53-900e-947df8979783</incoming>
      <outgoing>node_926398936983_sequence</outgoing>
    </sendTask>
    <sequenceFlow id="sequenceFlow_76b564f1-d4ad-4d53-900e-947df8979783" sourceRef="root" targetRef="node_616935911517"/>
    <sequenceFlow id="node_926398936983_sequence" sourceRef="node_616935911517" targetRef="node_926398936983">
      <extensionElements>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.sequence.UserTaskIncomingListener" event="take"/>
      </extensionElements>
    </sequenceFlow>
    <userTask camunda:assignee="${user}" id="node_926398936983" name="审批人">
      <documentation id="documentation_dc99fedc-fc7b-4985-b80a-bea805b02699">{"assignedType":["ASSIGN_USER"],"mode":"NEXT","sign":false,"formPerms":null,"nobody":{"handler":"TO_EXCEPTIONAL","assignedUser":[]},"timeLimit":null,"assignedUser":[{"id":"1580726129128992770","name":"186-超级管理员","type":1},{"id":"1659398930563702785","name":"刘法手机","type":1},{"id":"1585094725347098626","name":"11111","type":2}],"selfSelect":null,"leaderTop":null,"leader":null,"roleOrg":{"role":[],"roleOrgType":"ALL","org":[]},"refuse":null,"formUser":null}</documentation>
      <extensionElements>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.create.UserTaskCreateListener" event="create"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.complete.UserTaskCompleteListener" event="complete"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.delete.UserTaskDeleteListener" event="delete"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.assignment.UserTaskAssignmentListener" event="assignment"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.update.UserTaskUpdateListener" event="update"/>
        <camunda:inputOutput>
          <camunda:inputParameter name="approvalMode">NEXT</camunda:inputParameter>
          <camunda:inputParameter name="userTaskType">APPROVAL</camunda:inputParameter>
          <camunda:inputParameter name="nobodyHandler">TO_EXCEPTIONAL</camunda:inputParameter>
        </camunda:inputOutput>
      </extensionElements>
      <incoming>node_926398936983_sequence</incoming>
      <outgoing>node_839328175114_sequence</outgoing>
      <multiInstanceLoopCharacteristics camunda:collection="${users}" camunda:elementVariable="user" id="multiInstanceLoopCharacteristics_55826d3e-2ded-467b-a8ea-3be1ae6e102e" isSequential="true">
        <completionCondition id="completionCondition_08ebe6ea-749f-4dc8-bd8b-55b0428db83b">${nrOfCompletedInstances == nrOfInstances}</completionCondition>
      </multiInstanceLoopCharacteristics>
    </userTask>
    <sequenceFlow id="node_839328175114_sequence" sourceRef="node_926398936983" targetRef="node_839328175114">
      <extensionElements>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.sequence.UserTaskIncomingListener" event="take"/>
      </extensionElements>
    </sequenceFlow>
    <userTask camunda:assignee="${user}" id="node_839328175114" name="审批人">
      <documentation id="documentation_621470e6-df17-4fb1-8fad-86011e0b344c">{"assignedType":["ASSIGN_USER"],"mode":"OR","sign":false,"formPerms":null,"nobody":{"handler":"TO_PASS","assignedUser":[]},"timeLimit":null,"assignedUser":[{"id":"1580726129128992770","name":"186-超级管理员","type":1},{"id":"1659398930563702785","name":"刘法手机","type":1},{"id":"1572769134128214018","name":"张柱11","type":1},{"id":"1613445750961299458","name":"洪小霞","type":1}],"selfSelect":null,"leaderTop":null,"leader":null,"roleOrg":{"role":[],"roleOrgType":"UNKNOWN","org":[]},"refuse":null,"formUser":null}</documentation>
      <extensionElements>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.create.UserTaskCreateListener" event="create"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.complete.UserTaskCompleteListener" event="complete"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.delete.UserTaskDeleteListener" event="delete"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.assignment.UserTaskAssignmentListener" event="assignment"/>
        <camunda:taskListener class="com.hfky.workflow.server.module.camunda.listener.task.usertask.update.UserTaskUpdateListener" event="update"/>
        <camunda:inputOutput>
          <camunda:inputParameter name="approvalMode">OR</camunda:inputParameter>
          <camunda:inputParameter name="userTaskType">APPROVAL</camunda:inputParameter>
          <camunda:inputParameter name="nobodyHandler">TO_PASS</camunda:inputParameter>
        </camunda:inputOutput>
      </extensionElements>
      <incoming>node_839328175114_sequence</incoming>
      <outgoing>sequenceFlow_39966a65-6409-4301-bd22-566da3f0abc5</outgoing>
      <multiInstanceLoopCharacteristics camunda:collection="${users}" camunda:elementVariable="user" id="multiInstanceLoopCharacteristics_2ee36c6f-a743-44e8-96f1-5a9153434859" isSequential="false">
        <completionCondition id="completionCondition_4c099868-903c-4c86-b1b3-7e60f78c96e6">${nrOfCompletedInstances == 1}</completionCondition>
      </multiInstanceLoopCharacteristics>
    </userTask>
    <endEvent id="end" name="结束">
      <extensionElements>
        <camunda:executionListener class="com.hfky.workflow.server.module.camunda.listener.end.EndEventEndListener" event="end"/>
      </extensionElements>
      <incoming>sequenceFlow_39966a65-6409-4301-bd22-566da3f0abc5</incoming>
    </endEvent>
    <sequenceFlow id="sequenceFlow_39966a65-6409-4301-bd22-566da3f0abc5" sourceRef="node_839328175114" targetRef="end"/>
    <textAnnotation id="textAnnotation_e2d2a588-caf6-466e-8b93-29cdb683f4fd">
      <text>审批节点/顺序依次审批/流程异常</text>
    </textAnnotation>
    <association id="association_6f8c3357-dce9-4d5a-9596-720975abad36" sourceRef="node_926398936983" targetRef="textAnnotation_e2d2a588-caf6-466e-8b93-29cdb683f4fd"/>
    <textAnnotation id="textAnnotation_84c4a034-2871-4275-affd-4111c89f2f48">
      <text>审批节点/或签/直接通过</text>
    </textAnnotation>
    <association id="association_6138d9c4-bf25-4f0d-b7ea-eadf4b06233a" sourceRef="node_839328175114" targetRef="textAnnotation_84c4a034-2871-4275-affd-4111c89f2f48"/>
  </process>
  <bpmndi:BPMNDiagram id="BPMNDiagram_18a5de55-9957-40e6-b43e-5ebde913cdf5">
    <bpmndi:BPMNPlane bpmnElement="process_SBJY" id="BPMNPlane_4328db3b-a050-4677-b4d6-22f5148b8739">
      <bpmndi:BPMNShape bpmnElement="root" id="BPMNShape_df1df4ed-7fcc-4d16-95e2-996bdab5097e">
        <dc:Bounds height="36.0" width="36.0" x="100.0" y="100.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape bpmnElement="node_616935911517" id="BPMNShape_20d93b31-b628-4844-b9e6-f95aaa374d26">
        <dc:Bounds height="80.0" width="100.0" x="186.0" y="78.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="sequenceFlow_76b564f1-d4ad-4d53-900e-947df8979783" id="BPMNEdge_7ce6d515-d414-470c-a10d-4faf4e827a9f">
        <di:waypoint x="136.0" y="118.0"/>
        <di:waypoint x="186.0" y="118.0"/>
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape bpmnElement="node_926398936983" id="BPMNShape_9a09848e-47b5-4cf9-ba4d-202fca0076eb">
        <dc:Bounds height="80.0" width="100.0" x="336.0" y="78.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="node_926398936983_sequence" id="BPMNEdge_6c227e09-8505-411f-b218-cccf6c7f6b62">
        <di:waypoint x="286.0" y="118.0"/>
        <di:waypoint x="336.0" y="118.0"/>
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape bpmnElement="textAnnotation_e2d2a588-caf6-466e-8b93-29cdb683f4fd" id="BPMNShape_9778beb2-f56e-4525-adeb-55521420d4ae">
        <dc:Bounds height="30.0" width="150.0" x="436.0" y="178.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="association_6f8c3357-dce9-4d5a-9596-720975abad36" id="BPMNEdge_9cf34fdc-3cda-4465-8bae-461a4b97d085">
        <di:waypoint x="386.0" y="158.0"/>
        <di:waypoint x="436.0" y="193.0"/>
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape bpmnElement="node_839328175114" id="BPMNShape_2adea32c-7b35-4ed9-93dd-5d4d9b5c42e4">
        <dc:Bounds height="80.0" width="100.0" x="486.0" y="78.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="node_839328175114_sequence" id="BPMNEdge_cb1c6de5-6bf5-496e-bf67-577bee2c033c">
        <di:waypoint x="436.0" y="118.0"/>
        <di:waypoint x="486.0" y="118.0"/>
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape bpmnElement="textAnnotation_84c4a034-2871-4275-affd-4111c89f2f48" id="BPMNShape_ad901588-3b14-4870-9b4a-8061053332e5">
        <dc:Bounds height="30.0" width="150.0" x="586.0" y="178.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="association_6138d9c4-bf25-4f0d-b7ea-eadf4b06233a" id="BPMNEdge_5da81668-e368-42a5-90b7-7751795cd44e">
        <di:waypoint x="536.0" y="158.0"/>
        <di:waypoint x="586.0" y="193.0"/>
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNShape bpmnElement="end" id="BPMNShape_6f6c1e50-adde-4c61-8f9b-6f043ebda337">
        <dc:Bounds height="36.0" width="36.0" x="636.0" y="100.0"/>
      </bpmndi:BPMNShape>
      <bpmndi:BPMNEdge bpmnElement="sequenceFlow_39966a65-6409-4301-bd22-566da3f0abc5" id="BPMNEdge_41edea4e-b4c5-42db-9787-e5a2faf04c20">
        <di:waypoint x="586.0" y="118.0"/>
        <di:waypoint x="636.0" y="118.0"/>
      </bpmndi:BPMNEdge>
    </bpmndi:BPMNPlane>
  </bpmndi:BPMNDiagram>
</definitions>

```

例如有上面的示例 XML 
现在想获取 id 为 node_839328175114 的 userTask 的 documentation 的值
使用

```sql
select extractvalue(@xml, '/definitions/process/userTask[@id="node_839328175114"]/documentation');
```

这里我的场景是官方文档没有提到的， 做个简记
官方文档: https://dev.mysql.com/doc/refman/8.0/en/xml-functions.html
