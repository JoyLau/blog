---
title: 人生从未写过如此有趣的代码
date: 2017-9-4 10:02:58
description: '<center><img src="//image.joylau.cn/blog/an-interesting-code.png"></center>  <br>哥们向我请教家庭问题的解决办法，我给了他这样的代码'
categories: [程序员篇]
tags: [程序员,算法]
---
<!-- more -->
<center>
![an-interesting-code](//image.joylau.cn/blog/an-interesting-code-img1.png)
![an-interesting-code](//image.joylau.cn/blog/an-interesting-code-img2.png)
![an-interesting-code](//image.joylau.cn/blog/an-interesting-code-img3.png)
![an-interesting-code](//image.joylau.cn/blog/an-interesting-code.png)
</center>


``` java
    package cn.joylau.code.test;
    
    /**
     * Created by JoyLau on 2017/9/4.
     * cn.joylau.code.test
     * 2587038142@qq.com
     */
    public class Run {
        public static void main(String[] args) {
            /*定义老妈对象*/
            Mother mother = new Mother();
            /*定义老婆对象*/
            Wife wife = new Wife();
            /*开始解释昨晚发生的事情*/
            //返回老婆解释的结果（成功 或者失败）
            boolean w_success = explainToMotherOrWife(wife);
            //返回老妈解释的结果（成功 或者失败）
            boolean m_success = explainToMotherOrWife(mother);
            try {
                // 如果解释都成功了
                if (w_success && m_success){
                    // 愉快的吃晚饭
                } else{
                    // 如果有一方解释失败
                    //开始开家庭会议，已达成一致意见
                    familyMetting();
                }
            } catch (Exception e) {
                // 如果过程中出现任何异常，程序将无法处理，抛出异常，你将会很痛苦
                e.printStackTrace();
                // 这个时候为了缓解你的痛苦，程序为你准备了一种放松的方法
                // 和法哥来一把激动人心的 LOL
                playLOLWithFa();
            }
        }
    
        /**
         * 向 老妈 或者 老婆 解释 昨晚发生的事情
         * @param object 老妈 或者 老婆
         * @return 解释是否成功
         */
        private static boolean explainToMotherOrWife(Object object){
            // 如果对象是 老妈,则向老妈开始解释
            if (object instanceof Mother) {
                Mother mother = (Mother)object;
                // 解释过程
                // ......
                // 返回向老妈解释的结果
                return mother.acceptExplain();
            // 如果对象是老婆,则向老婆开始解释
            } else {
                Wife wife = (Wife)object;
                // 解释过程
                // ......
                // 返回向老婆解释的结果
                return wife.acceptExplain();
            }
        }
    
        /**
         * 开家庭会议
         */
        private static void familyMetting(){
            System.out.println("balabala");
        }
    
        /**
         *  与法哥一起玩游戏
         */
        private static void playLOLWithFa() {
            System.out.println("PentaKill");
            System.out.println("66666!~");
        }
    }
```
