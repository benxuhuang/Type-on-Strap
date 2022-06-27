---
layout: post
title: C#委派與Lambda表示式
color: turquoise
feature-img: "/assets/post-imgs/thumbnails/code-monitor-2.jpg"
thumbnail: "/assets/post-imgs/thumbnails/code-monitor-2.jpg"
excerpt_separator: <!--more-->
tags:
  - C#
  - Lambda
---


### 使用委派的時機?

當我們在設計類別時，可能會碰到某些商業邏輯細節不想寫死在類別中，此時我們可以透過委派將這部分的程式碼抽離至呼叫端(Client)。

將變化太多或可能無法預先得知的商業邏輯規則從類別中移出，可以讓類別設計更加的簡潔。

<!--more-->

### 撰寫委派的步驟

1. 宣告委派型別
2. 撰寫委派方法
3. 建立委派物件，並指定委派方法。
4. 透過委派物件執行委派方法

### 委派語法的演進

C# 1.0 -> C# 2.0 -> C# 3.0

```csharp
using System;
using System.Collections.Generic;
 
namespace DelegateSample
{
    class Program
    {
        static void Main(string[] args)
        {
            var result = "";
            var cs1 = new CSharp1();
 
            //建立委派物件，並指定委派方法
            //C# 1.0 委派寫法
            Predicate p = new Predicate(cs1.FindDog);
            result = cs1.FindAnimalByDelegate(p);
            Console.WriteLine("find dog:{0}", result);
 
            //C# 2.0 委派寫法
            result = cs1.FindAnimalByDelegate(cs1.FindCat);
            Console.WriteLine("find cat:{0}", result);
 
            //(C# 3.0 lambda expression 委派寫法)
            Predicate p2 = (IList<string> list) =>
            { 
                return list.Contains("cow"); 
            };
            result = cs1.FindAnimalByDelegate(p2);
            Console.WriteLine("find cow:{0}", result);
        }
    }
 
    //宣告委派型別
    public delegate bool Predicate(IList<string> list);
 
    public class CSharp1
    {
        private IList<string> _animals;
 
        public CSharp1()
        {
            _animals = new List<string>() {"dog","cat","bird"};
        }
 
        public string FindAnimalByDelegate(Predicate p)
        {
            //透過委派物件執行委派方法
            var isExist = p(_animals);
            return isExist.ToString();
        }
 
        public bool FindDog(IList<string> list)
        {
            return list.Contains("dog");
        }
 
        public bool FindCat(IList<string> list)
        {
            return list.Contains("cat");
        }
 
        public bool FindCow(IList<string> list)
        {
            return list.Contains("cow");
        }
    }
}
```

### 泛型委派

泛型委派的型別參數決定委派方法的形式參數

delegate R 委派型別名稱<T1, T2, …, Tn, R>(T1 t1, T2 t2, …, Tn tn)
- 委派關鍵字: delegate
- 傳回型別(可於型別參數中設定回傳型別): R 
- 型別參數列: <T1, T2, …, Tn, R> 
- 形式參數列: (T1 t1, T2 t2, … , Tn tn)


```csharp
using System;
 
namespace GenericDelegateSample
{
    delegate void MyDelegate<T>(T param);
 
    class Program
    {
        static void Main(string[] args)
        {
            var work = new Worker();
            var delegateObject = new MyDelegate<string>(work.Print);
            delegateObject("hi, Generic Delegate");
            delegateObject.Invoke("hi, Generic Delegate");
        }
    }
 
    class Worker
    {
        public void Print(string s)
        {
            Console.WriteLine(s);
        }
    }
}
```

### 使用 .Net Framework 現成的泛型委派方法

`Action<T>`
```csharp
delegate void Action<in T>(T arg);
delegate void Action<in T1, in T2>(T1 arg1, T2 arg2);
delegate void Action<in T1, in T2, in T3>(T1 arg1, T2 arg2, T3 arg3);
```

`Func<T>`
```csharp
delegate TResult Func<out TResult>();
delegate TResult Func<in T, out TResult>(T arg);
delegate TResult Func<in T1, in T2, out TResult>(T1 arg1, T2 arg2);
```

以上 `Action<T>` 與 `Func<T>` 最多可傳入16個型別參數

```csharp
using System;
 
namespace GenericDelegateSample
{
    delegate void MyDelegate<T>(T param);
 
    class Program
    {
        static void Main(string[] args)
        {
            var work = new Worker();
            var actionDelegate = new Action<string>(work.Print);
            actionDelegate("hi, Generic Delegate");
        }
    }
 
    class Worker
    {
        public void Print(string s)
        {
            Console.WriteLine(s);
        }
    }
}
```

### 建立委派的幾種作法

1.匿名方法

```csharp
Predicate<int> pd = delegate(int x)
{
   return x > 20;
}
```

2.Lambda 表示式

一種匿名函式(anonymous function)，包含`運算式(expressions)`和`陳述式(statements)`，可用來建立委派或表示式樹狀架構(expression tree)型別。

運算式(expressions)

```csharp
Predicate<int> pd = (string s) =>
{
   return s.EndWith("go");
}
```

陳述式(statements)

```csharp
Predicate<int> pd = (string s) => s.EndWith("go");
Predicate<int> pd = (s) => s.EndWith("go");
Predicate<int> pd =   s => s.EndWith("go");
```

### 運算式樹(Expression tree)

運算式 lambda 除了可以轉換成委派物件外，還可以轉成運算式樹(expression tree)。

我們可以將運算式轉成樹狀資料結構並存到運算式樹中

```csharp
Func<int, int> fn = n => n * n; 
Console.WriteLine(fn(10)); 
 
//運算式轉成樹狀資料結構並存到運算式樹中
Expression<Func<int, int>> expr = n => n * n;
 
// 將樹狀結構逆向轉為程式碼，並存入委派物件。
Func<int, int> fn = expr.Compile(); 
 
Console.WriteLine(fn(10));
```



原本的泛型委派 `Func<int, int>` 被傳入另外一個泛型委派 Expression<T> 中，當 lambda 運算式變成一種資料結構時，我們就可以將程式碼當資料處理，所以 expression tree 可以用來建立動態查詢。