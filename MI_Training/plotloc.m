clear, close all; clc;
chanloc=pop_chanedit('');
[fileName, filePath]=uiputfile('*.mat');
save([filePath fileName], 'chanloc');
