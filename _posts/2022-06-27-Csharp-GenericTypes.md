---
layout: post
title: C# GenericTypes 泛型類別
color: turquoise
feature-img: /assets/post-imgs/thumbnails/pexels-caio-69976.jpg
thumbnail: /assets/post-imgs/thumbnails/pexels-caio-69976.jpg
excerpt_separator: <!--more-->
tags:
  - C#
  - GenericTypes
---

### 泛型出現的原因

當C#還沒有泛型時，如果我們要儲存不確定數量的資料到變數時，我們可能會使用ArrayList來處理，在沒有泛型的情況下，我們必須使用以下的方式撰寫:

<!--more-->

```csharp
using System.Collections;
 
namespace GenericTypesSample
{
    partial class Program
    {
        static void Main(string[] args)
        {
            ArrayList intList = new ArrayList();
            intList.Add(100);
            intList.Add(200);
            intList.Add("string");
 
            int i1 = intList[0]; //無法通過編譯，需要明確轉型!
            int i2 = (int)intList[1];
            int i3 = (int)intList[2]; //會有轉型失敗問題
        }
    }
}
```

以上的作法會發生以下兩種問題:

1.手動轉型問題

因為ArrayList是屬於System.Collections命名空間的集合類別，所以當物件存入ArrayList時會自動被轉成Object型別，故要取用ArrayList資料時必須要明確轉型，否則無法通過編譯器檢查。

2.執行期型別轉換問題

另一個問題為如果不小心將明確轉型的目標型別寫成來源物件不相容的型別，這種情況下編譯器無法檢查出來，會造成執行期錯誤，無法達到編譯期的型別安全檢查效果。

除了以上的問題外，還可能需要對每一個類型撰寫各自的集合類別，最後這些自訂類別可能會產生大量的重複程式碼，當未來需要增加新的方法或是屬性時，就必須逐一修改，最後導致維護成本的增加。

泛型的出現就是為了解決以上問題

### 泛型基本語法
泛型可用於類別、介面、委派和方法，以下是泛型類別的基本語法

```csharp
class 類別名稱<T1, T2,..., Tn>
{
   ...
}
型別參數: <T1, T2,..., Tn>
```

### 開放型別、建構型別
`類別名稱<T>` 並不是真正用來建立物件實體的類別，僅是一個樣板，又稱作`開放型別(open type)`。有帶入型別參數的類別，才是可以用來建立物件實體的類別，又稱作`建構型別(constructed type)`或`關閉型別(closed type)`。

```csharp
static void Main(string[] args)
{
    //使用建構型別來建立物件實體
    var list = new intList<int>();
}
 
/// <summary>
/// 開放型別
/// </summary>
/// <typeparam name="T"></typeparam>
public class intList<T>
{
    public List<T> model { get; set; }
}
```

### 使用既有泛型來產生另一個開放型別

```csharp
namespace GenericTypesSample
{
    public class GenericList<T>
    {
    }
 
    public class StackList<T>
    {
        private GenericList<Stack<T>> stackList;
    }
}
```

### 型別參數條件約束

**在 .NET 中任何型別皆繼承自 System.Object**，當要在泛型類別中存取T的物件實體成員時，就只能有 Object 的成員可以使用，例如 `Equals()`、`GetType()`、`ToString()` 等等。

但有時候我們會需要存取參數型別的方法或屬性，例如我們想使用 Compare 方法來比較兩個物件，這時候如果像下面這個寫，編譯器會顯示錯誤，型別無法對應到特定方法。

```csharp
public class GenericList<T>
{
    public T Models { get; set; }
 
    public int Compare(T obj1, T obj2)
    {
        return obj1.CompareTo(obj2); //編譯器顯示錯誤
    }
}
```

此時就可以透過 where 條件約束來限定可傳入的型別，限定傳入的型別可以讓編譯器知道傳入型別參數 T 的相關成員，例如以上面這個 Compare 當例子，我們必須實作 `IComparable<T>`。

```csharp
public class GenericList<T> where T: IComparable<T>
{
    public T Models { get; set; }
 
    public int Compare(T obj1, T obj2)
    {
        return obj1.CompareTo(obj2);
    }
}
```

泛型約束可以限制實作多個介面或繼承一個類別

```csharp
using System;
namespace GenericTypesSample
{
    public class MyPair<TKey, TValue>
        where TKey: MyKey, IComparable<TKey>, IEquatable<TKey>, new()
        where TValue: struct, IEquatable<TKey>
    {
    }
 
    public class MyKey
    {
    }
}
```

### 泛型介面、泛型結構

我們也可以使用泛型語法來定義泛型介面與泛型結構，我們可以**將類別中的基本操作或屬性抽離出來放在泛型介面**，如下我們將共用的屬性抽離成泛型介面，並由另外一個泛型類別繼承與實作。

```csharp
namespace GenericTypesSample
{
    public interface IMyList<T>
    {
        public int Count { get; }
        T this[int index]
        {
            get;
            set;
        }
    }
 
    public class GenericIntList<T>: IMyList<T>
        where T: IComparable<T>
    {
        private ArrayList _elements;
 
        public int Count => _elements.Count;
 
        /// <summary>
        /// constructor 建構式
        /// </summary>
        public GenericIntList()
        {
            _elements = new ArrayList();
        }
 
        /// <summary>
        /// finalizer 解構式
        /// </summary>
        ~GenericIntList()
        {
 
        }
 
        public void Add(T num)
        {
            _elements.Add(num);
        }
 
        public T this[int index]
        {
            get
            {
                return (T)_elements[index];
            }
 
            set
            {
                _elements[index] = value;
            }
        }
 
        public void GenerateItems(int numOfItems)
        {
            T[] arr = new T[numOfItems];
 
            for (int i = 0; i < numOfItems; i++)
            {
                arr[i] = default(T); // setting the default value of T
            }
        }
 
        public int Compare(T obj1, T obj2)
        {
            return obj1.CompareTo(obj2);
        }
 
    }
}
```

### 泛型方法

泛型方法不一定只能宣告在泛型內，也能宣告在一般的型別中，例如類別、介面、結構。

```csharp
public class GenericMethod
{
    public void Print<T>(T obj)
    {
        Console.WriteLine(" 參數值：" + obj.ToString());
    }
 
    public TResult Print<T, TResult>(T obj) where TResult : new()
    {
        Console.WriteLine(" 參數值：" + obj.ToString());
        TResult result = new TResult();
        return result;
    }
}
```

### 泛型型別相容問題

型別相容主要包含三個核心概念: `共變性(Covariance)`、`逆變性(Contravariance)`、`不變性(Invariance)`。

1.共變性(Convariance): 如果型別A繼承自型別B，則A可以隱含自動轉型為B，此概念則稱為具有共變性。以下的範例，因C#中的任何型別皆繼承自Object型別，所以我們可以將字串陣列直接Assign給物件陣列而不會發生異常，這就是共變性的特性。

```csharp
string[] strArr = new string[5];
object[] objArr = strArr;
```

2.不變性(Invariance): 泛型本身具有不變性(Invariance)，所以你無法把一個`List<string>`型別的物件Assign給`List<object>`物件，子類與父類不能互相取代。

```csharp
List<string> strList = new List<string>();
List<object> objList = strList; //編輯器錯誤
```

但 .NET Framework 4 針對泛型支援`共變性(Covariance)`與`逆變性(Contravariance)`，透過 C# 4 所提供的 in 與 out 兩個修飾詞來支援以上特性。

以 `IEnumerable<out T>` 為例，因為 `IEnumerable<out T>` 的參數為 out T，表明參數 T 只能當作回傳值使用，這就是支援共變性(Covariance)的做法，但也因為僅能當回傳值用，所以 `IEnumerable<T>` 並不支援串列元素修改、更新，僅能唯讀使用。

```csharp
public interface IEnumerable<out T> : IEnumerable
{
    IEnumerable<T> GetEnumerator();
}
List<string> strList = new List<string>();
IEnumerable<object> objList = strList;
```

3.逆變性(Contravariance): in 修飾詞來支援泛型逆變性，以下以 `IComparer<in T>` 當例子

```csharp
public class Course {
    public int Id { get; set; }
    public int Score { get; set; }
}
 
public class Chinese: Course { }
 
public class ScoreComparer: IComparer<Course>
{
    public int Compare(Course obj1, Course obj2)
    {
        return obj1.Score - obj2.Score;
    }
}
 
public class Contravariance
{
    public void Main()
    {
        List<Chinese> chinese = new List<Chinese>() { 
            new Chinese() { Id=1, Score = 80},
            new Chinese() { Id=2, Score = 85},
            new Chinese() { Id=3, Score = 90},
        };
 
        IComparer<Course> courseComparer = new ScoreComparer();
        chinese.Sort(courseComparer);
        foreach (var item in chinese)
           Console.WriteLine(item.Id);        
    }
}
```

以下是 IComparer\<in T> 的原型宣告

```csharp
public interface IComparer<in T>
{
    int Compare(T? x, T? y);
}
```

因為 `IComparer<in T>` 的參數限定為只能當參數，以上面的例子在 `chinese.Sort(courseComparer)`時，原本我們必須傳入繼承的型別 `IComparer<Chinese>`，但我們卻傳入被繼承的型別 `IComparer<Course>`，在這裡就發生了所謂的`逆變性(Contravariance)` 。