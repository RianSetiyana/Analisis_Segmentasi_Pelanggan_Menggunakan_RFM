# Analisis Segmentasi Pelanggan Menggunakan RFM

# Ringkasan

Proyek ini bertujuan untuk mengelompokkan pelanggan berdasarkan perilaku transaksi mereka menggunakan metode RFM (Recency, Frequency, Monetary). Dengan menggunakan data [Superstore](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final), dari 693 pelanggan dihasilkan 5 segmen utama yaitu Champions, Loyal Customers, New/Promising, At Risk, dan Lost. Hasil segmentasi kemudian divisualisasikan melalui dashboard interaktif di Power BI untuk memudahkan pemahaman karakteristik tiap segmen dan mendukung pengambilan keputusan strategi bisnis.

# Tujuan

1. Mengelompokkan pelanggan berdasarkan perilaku transaksi mereka menggunakan metode RFM.
2. Memberikan rekomendasi strategi bisnis berdasarkan karakteristik setiap segmen pelanggan.

# Rumusan Masalah

1. Bagaimana distribusi pelanggan berdasarkan segmentasi RFM?
2. Bagaimana karakteristik setiap segmen pelanggan berdasarkan metrik RFM?

# Ruang Lingkup

Analisis difokuskan pada tahun 2017 sebagai representasi performa terbaru perusahaan.

# Tools yang Digunakan

## 1. PostgreSQL

Digunakan untuk menulis query dalam proses pengambilan, pembersihan, dan pemfilteran data.

## 2. Python

Digunakan sebagai alat utama dalam proses pengolahan dan analisis data. Library yang digunakan pada proyek ini antara lain:

- Pandas: Digunakan untuk manipulasi dan pengolahan data.
- Matplotlib: Digunakan sebagai dasar visualisasi data.
- Seaborn: Digunakan untuk membuat visualisasi yang lebih informatif.

## 3. Power BI

Digunakan untuk membangun dashboard yang merangkum hasil analisis.

# Persiapan Data

Pada tahap ini dilakukan standarisasi format tanggal, pembuatan fitur waktu, serta pemfilteran data pada tahun 2017 agar data siap untuk dianalisis lebih lanjut.

Detail proses persiapan data dapat dilihat pada file berikut: [Data_Preparation](SQL/Data_Preparation.sql)

### Memfilter Data

```sql
SELECT
	*
FROM
	CLEANED_DATA
WHERE
	ORDER_YEAR = 2017
	AND SALES IS NOT NULL;
```

# Proses Analisis

Setiap notebook pada proyek ini difokuskan untuk menjawab satu pertanyaan dari rumusan masalah. Berikut pendekatan analisis yang digunakan pada masing-masing notebook:

## Segmentasi Pelanggan

Proses diawali dengan menetapkan tanggal acuan sebagai titik  referensi perhitungan recency, kemudian dilakukan agregasi data  untuk mendapatkan nilai recency, frequency, dan monetary tiap  pelanggan. Setiap metrik kemudian diberi skor 1-5 menggunakan  metode kuantil, di mana skor tertinggi mencerminkan perilaku  paling menguntungkan. Kombinasi skor RFM selanjutnya dipetakan  ke dalam label segmen bisnis seperti Champions, Loyal Customers,  At Risk, dan lainnya. Hasil segmentasi kemudian divisualisasikan  menggunakan Treemap untuk menampilkan komposisi dan proporsi  tiap segmen secara keseluruhan.

Detail proses analisis dapat dilihat pada notebook berikut: [1_Customer_Segmentation](Python/1_Customer_Segmentation.ipynb)

### Visualisasi Data

```python
df_plot = df_RFM['segment'].value_counts()
labels = [f'{index}\n{values} ({(values / df_plot.sum()) * 100:.1f}%)' for index, values in zip(df_plot.index, df_plot.values)]
colors = sns.color_palette('dark:magenta', n_colors=5)

plt.figure(figsize=(7,4))
squarify.plot(sizes=df_plot.values, label=labels, color=colors, ec='white', lw=3,
              text_kwargs={'size':10,'weight':'bold','color':'white'})

title_dict = {'size':12,
              'weight':'bold',
              'color':'black',
              'loc':'center',
              'pad':10,
              'rotation':0,
              'alpha':1,
              'family':plt.rcParams['font.family']}

plt.title('Where Does Our Customer Base Stand?', **title_dict)

plt.tight_layout()
plt.axis(False)
plt.show()
```

### Hasil

![Treemap](Images/Treemap.PNG)

## Karakteristik Segmen Pelanggan

Proses diawali dengan memuat dataset hasil olahan dari notebook sebelumnya (`RFM_dataset.csv`) yang sudah mengandung informasi skor dan label segmen tiap pelanggan, sehingga proses segmentasi tidak perlu diulang kembali. Selanjutnya dihitung nilai median untuk metrik recency, frequency, dan monetary pada setiap segmen pelanggan. Hasil perhitungan kemudian divisualisasikan menggunakan Bar Chart untuk memudahkan perbandingan perilaku antar segmen secara langsung.

Detail proses analisis dapat dilihat pada notebook berikut: [2_Customer_Segment_Characteristics](Python/2_Customer_Segment_Characteristics.ipynb)

### Visualisasi Data

```python
columns = ['recency', 'frequency', 'monetary']
datas = [df_median[column].sort_values(ascending=False) for column in columns]
titles = ['How Long Since Their Last Purchase?', 'How Often Do They Shop With Us?', 'How Much Revenue Do They Generate?']

fig, ax = plt.subplots(nrows=1, ncols=3, figsize=(20,5))

for i in range(len(ax)):
    df_plot = datas[i]
    
    if df_plot.name == 'recency':
        labels = [f'{r:.0f} Days' for r in df_plot.values]
    elif df_plot.name == 'frequency':
        labels = [f'{f:.0f} Time(s)' for f in df_plot.values]
    else:
        labels = [f'${m:.0f}' for m in df_plot.values]
    
    sns.barplot(x=df_plot.values, y=df_plot.index, ax=ax[i], color='#63adf2', ec='black', ls='-', lw=0.8, alpha=1)
    
    title_dict = {'size':12,
              'weight':'bold',
              'color':'black',
              'loc':'left',
              'pad':10,
              'rotation':0,
              'alpha':1,
              'family':plt.rcParams['font.family']}
    
    ax[i].set_title(f'{titles[i]}', **title_dict)
    ax[i].set_ylabel('')
    
    ax[i].tick_params(which='major', axis='both', color='black', direction='out', left=False, bottom=False)
    ax[i].set_xticklabels('')
    
    container = ax[i].containers[0]
    ax[i].bar_label(container=container, labels=labels, size=10, weight='normal', color='black', padding=5)
    
    sns.despine(left=True, bottom=True, ax=ax[i])

plt.tight_layout()
plt.show()
```

### Hasil

![RFM](Images/RFM.PNG)

# Insights

Berikut beberapa temuan utama yang diperoleh dari hasil analisis:

- **Loyal Customers mendominasi basis pelanggan, namun segmen At Risk perlu diwaspadai**: Berdasarkan hasil segmentasi, Loyal Customers merupakan segmen terbesar dengan 192 pelanggan (27.7%), diikuti At Risk sebesar 154 pelanggan (22.2%). Hal ini menunjukkan bahwa meskipun bisnis memiliki basis pelanggan setia yang kuat, hampir seperempat pelanggan berisiko untuk tidak kembali bertransaksi sehingga diperlukan strategi retensi yang tepat.
- **Champions adalah segmen paling berharga meskipun jumlahnya paling sedikit**: Dengan hanya 98 pelanggan (14.1%), segmen Champions mencatatkan median recency terendah (22 hari), frequency tertinggi (4 kali), dan monetary tertinggi ($1,580). Sebaliknya, segmen Lost memiliki median recency tertinggi (187 hari) dengan monetary terendah ($121), mengindikasikan pelanggan yang sudah lama tidak bertransaksi dan memiliki nilai rendah bagi bisnis.

# Dashboard Overview

Bagian ini menyajikan dashboard interaktif yang dibangun untuk memantau kondisi basis pelanggan secara menyeluruh berdasarkan hasil segmentasi RFM. Fokus utamanya adalah memvisualisasikan distribusi segmen pelanggan serta membandingkan karakteristik perilaku transaksi antar segmen. Hal ini mencakup seberapa baru mereka bertransaksi, seberapa sering mereka berbelanja, hingga seberapa besar nilai yang mereka hasilkan bagi bisnis.

File dashboard dapat dilihat disini: [My_Dashboard](Power_BI/My_Dashboard.pbix)

### Tampilan Dashboard:

![My_Dashboard](Images/My_Dashboard.PNG)

# Kesimpulan

Berdasarkan hasil analisis, ditemukan bahwa basis pelanggan didominasi oleh Loyal Customers (27.7%), namun segmen At Risk (22.2%) menjadi perhatian utama karena hampir seperempat pelanggan berisiko untuk tidak kembali bertransaksi. Di sisi lain, Champions terbukti menjadi segmen paling berharga meskipun jumlahnya paling sedikit (14.1%). Berdasarkan temuan tersebut, berikut adalah rekomendasi strategi yang dapat diterapkan:

- **Mempertahankan Champions**: Berikan reward eksklusif atau loyalty program untuk menjaga keterlibatan segmen ini agar tetap aktif bertransaksi.
- **Meningkatkan nilai Loyal Customers**: Tawarkan upselling atau produk premium untuk mendorong peningkatan nilai transaksi mereka.
- **Mereaktivasi segmen At Risk**: Terapkan win-back campaign seperti penawaran khusus atau reminder sebelum mereka benar-benar berhenti bertransaksi.
- **Mendorong transaksi kedua dari New/Promising**: Berikan pengalaman yang baik dan insentif untuk mendorong pembelian berulang dari segmen yang berpotensi ini.
- **Mengevaluasi segmen Lost**: Pertimbangkan apakah layak untuk melakukan reactivation campaign atau lebih fokus mengalokasikan sumber daya ke segmen yang lebih potensial.