public with sharing class CSV_RowReader implements Iterator<String>, Iterable<String>{
    private String data;
    private Integer indx = 0;
    private String lineDelimiter = '\n';
    
    public CSV_RowReader(String sFileData){
        data = sFileData; 
    }
    public CSV_RowReader(String sFileData, String rowDelimiter){
        data = sFileData; 
        lineDelimiter = rowDelimiter;
    }
    
    public Boolean hasNext(){
        return indx < data.length() ? true : false;
    }
    
    public String next(){     
        Integer key = data.indexOf(lineDelimiter, indx);
        if (key == -1){
            key = data.length();
        }        
        String row = data.subString(indx, key);
        indx = key + 1;        
        return row;
    }
    
    public Iterator<String> Iterator(){
        return this;   
    }
}