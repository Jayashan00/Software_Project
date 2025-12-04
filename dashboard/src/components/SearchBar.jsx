import React from 'react';
import { Search } from 'lucide-react';

const SearchBar = () => {
  return (
    <div className="search-bar">
      <div className="search-bar__icon">
        <Search size={18} color="#999" />
      </div>
      <input 
        type="text" 
        className="search-bar__input" 
        placeholder="Find Something" 
      />
    </div>
  );
};

export default SearchBar;