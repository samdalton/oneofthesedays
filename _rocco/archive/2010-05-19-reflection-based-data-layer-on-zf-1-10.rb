#Working on a new project, I came up with this simple data layer. It uses Zend_Db_Tables to do most of the heavy lifting, but the added layer makes persisting objects a breeze.

#Here's how you use it

$store = new Application_Model_Persistence();
$user = $store->fetch('User', 'id', 5);
echo $user->name;

# Not much going on, really. The fetch method takes 3 arguments:
<ul>
	<li>The object you want</li>

	<li>The key you want to search on</li>

	<li>The value to search for the specified key</li>

</ul>

# The object name matches the table name in the database. The fetch method is looking for a model class of the name Application_Model_User, instantiating it, and then querying the database with a query select * where id = 5, from the table Zend_Db_DbTable_User.

# The Application_Model_User class is then populated with the returned database data, and subsequently returned to the user.

# A 'persist' method does the opposite. Given an object, it either creates a new entry in the database or updates an existing one.

# At the moment it can only handle primary key selects - multiple rowsets will probably cause it to crash.

# It does really simplify the actual implementation however, as you only need a single object to fetch, update, or create all of your data objects.

# Calling the fetch method 1000 times takes roughly 6 times longer than a raw sql query, but it's vastly quicker and simpler to implement with, and more convenient as the data is returned as an object.

# Here's the method
# For each type of model that is fetched, the dbTable object is stored here for quick access. Speeds up subsequent accesses in a single request by a factor of 6 or more.
	
protected $tableCache = array();

#Create an Application_Model_Template object of the given type, by selecting from the database querying on the given key with the given value. For example
#fetch me a location which has an id of 13
#fetch('Location', 'id', 13);
#@return Application_Model_Template
#@param string $type
#@param string $key
#@param mixed $value
#@throws Exception - Class name does not match DbTable name	
public function fetch($type, $key, $value) {
    $dbTable = $this->getDbTable($type);

    if (!$dbTable instanceof Zend_Db_Table_Abstract) {
	throw new Exception('Class name does not match DbTable name');
    }		
		
    $select = $dbTable->select();
    $select->where($key . ' = ?', $value);
    $row = $dbTable->fetchRow($select);
    
    try {
        $class = 'Application_Model_' . $type;
	$obj = new $class($row->toArray());
    } catch (Exception $e) {
	echo $e;
	return null;
    }	
	
    return $obj;
}


# Return an Application_Model_DbTable_dbTableName object for the given dbTableName. The tableCache is checked first using dbTableName as the key; if not found it is created, and stored in the cache.
# @return Application_Model_DbTable
# @param string $dbTableName

protected function getDbTable($dbTableName) {
    $dbTable = 'Application_Model_DbTable_' . $dbTableName;
		
    if ( array_key_exists($dbTableName, $this->tableCache) ) {
#cache hit
	return $this->tableCache[$dbTableName];
    } else {
# cache miss
        $this->tableCache[$dbTableName] = new $dbTable();
        return $this->tableCache[$dbTableName];
    }
}


# Mistakes, flaws, and potential security threats would be greatly appreciated! It's in no way complete, mainly proof of concept at present. I'd like to expand it with some real error checking, let it handle multiple rowsets, etc.
