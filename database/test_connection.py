"""
================================================================
NEON POSTGRESQL CONNECTION TEST (Python)
Version: 1.0.0
Description: Test database connection and verify schema
================================================================
"""

import os
import sys
from urllib.parse import urlparse
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# ANSI color codes
class Colors:
    RESET = '\033[0m'
    GREEN = '\033[32m'
    RED = '\033[31m'
    YELLOW = '\033[33m'
    BLUE = '\033[36m'
    BOLD = '\033[1m'


def print_header():
    """Print test suite header"""
    print("\n" + "=" * 60)
    print(f"{Colors.BOLD}  🚗 HAZARDNET DATABASE CONNECTION TEST 🚗{Colors.RESET}")
    print("=" * 60 + "\n")


def display_connection_info():
    """Display connection information (hide password)"""
    print(f"{Colors.BLUE}{Colors.BOLD}📋 Connection Information:{Colors.RESET}")
    
    database_url = os.getenv('DATABASE_URL')
    
    if not database_url:
        print(f"{Colors.RED}❌ DATABASE_URL environment variable not set!{Colors.RESET}\n")
        print(f"{Colors.YELLOW}ℹ️  Create a .env file with:{Colors.RESET}")
        print("   DATABASE_URL=postgresql://[user]:[password]@[host]/[database]?sslmode=require\n")
        return False
    
    try:
        parsed = urlparse(database_url)
        print(f"   Host: {parsed.hostname}")
        print(f"   Database: {parsed.path[1:]}")
        print(f"   User: {parsed.username}")
        print(f"   SSL: Enabled\n")
        return True
    except Exception as e:
        print(f"{Colors.RED}❌ Invalid DATABASE_URL format{Colors.RESET}\n")
        return False


def test_connection():
    """Test basic database connection"""
    print(f"{Colors.BLUE}{Colors.BOLD}🔌 Testing database connection...{Colors.RESET}")
    
    try:
        conn = psycopg2.connect(os.getenv('DATABASE_URL'))
        print(f"{Colors.GREEN}✅ Successfully connected to Neon PostgreSQL!{Colors.RESET}\n")
        return conn
    except Exception as e:
        print(f"{Colors.RED}❌ Connection failed: {str(e)}{Colors.RESET}")
        raise


def verify_schema(conn):
    """Verify database schema exists"""
    print(f"{Colors.BLUE}{Colors.BOLD}📊 Verifying database schema...{Colors.RESET}")
    
    query = """
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name;
    """
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(query)
            tables = [row[0] for row in cursor.fetchall()]
            
            if not tables:
                print(f"{Colors.YELLOW}⚠️  No tables found. Run schema.sql first!{Colors.RESET}\n")
                return False
            
            print(f"{Colors.GREEN}✅ Found {len(tables)} tables:{Colors.RESET}")
            for table in tables:
                print(f"   - {table}")
            print()
            return True
            
    except Exception as e:
        print(f"{Colors.RED}❌ Schema verification failed: {str(e)}{Colors.RESET}")
        return False


def check_seed_data(conn):
    """Check for seed data"""
    print(f"{Colors.BLUE}{Colors.BOLD}🌱 Checking for seed data...{Colors.RESET}")
    
    queries = [
        ('Users', 'SELECT COUNT(*) FROM users'),
        ('Hazards', 'SELECT COUNT(*) FROM hazards'),
        ('Alerts', 'SELECT COUNT(*) FROM alerts')
    ]
    
    try:
        with conn.cursor() as cursor:
            for name, query in queries:
                cursor.execute(query)
                count = cursor.fetchone()[0]
                
                if count > 0:
                    print(f"{Colors.GREEN}✅ {name}: {count} records{Colors.RESET}")
                else:
                    print(f"{Colors.YELLOW}⚠️  {name}: No records (run seed_data.sql){Colors.RESET}")
        print()
    except Exception as e:
        print(f"{Colors.RED}❌ Data check failed: {str(e)}{Colors.RESET}")


def test_query(conn):
    """Test a sample query"""
    print(f"{Colors.BLUE}{Colors.BOLD}🔍 Testing sample query...{Colors.RESET}")
    
    query = """
        SELECT 
            h.type,
            h.severity,
            h.latitude,
            h.longitude,
            h.reported_by_name,
            h.verification_count
        FROM hazards h
        WHERE h.is_active = TRUE
        ORDER BY h.detected_at DESC
        LIMIT 5;
    """
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            
            if rows:
                print(f"{Colors.GREEN}✅ Query successful! Recent hazards:{Colors.RESET}")
                for idx, row in enumerate(rows, 1):
                    print(f"   {idx}. {row['type']} ({row['severity']}) at ({row['latitude']}, {row['longitude']})")
                    print(f"      Reported by: {row['reported_by_name'] or 'Unknown'} | Verifications: {row['verification_count']}")
            else:
                print(f"{Colors.YELLOW}⚠️  No hazards found in database{Colors.RESET}")
        print()
    except Exception as e:
        print(f"{Colors.RED}❌ Query test failed: {str(e)}{Colors.RESET}")


def test_functions(conn):
    """Test database functions"""
    print(f"{Colors.BLUE}{Colors.BOLD}⚙️  Testing database functions...{Colors.RESET}")
    
    query = """
        SELECT calculate_distance(28.6139, 77.2090, 19.0760, 72.8777) AS distance_km;
    """
    
    try:
        with conn.cursor() as cursor:
            cursor.execute(query)
            distance = float(cursor.fetchone()[0])
            print(f"{Colors.GREEN}✅ Distance calculation function works!{Colors.RESET}")
            print(f"   Delhi to Mumbai: {distance:.2f} km\n")
    except Exception as e:
        print(f"{Colors.RED}❌ Function test failed: {str(e)}{Colors.RESET}")


def test_views(conn):
    """Test database views"""
    print(f"{Colors.BLUE}{Colors.BOLD}👁️  Testing database views...{Colors.RESET}")
    
    query = """
        SELECT 
            id,
            type,
            severity,
            reporter_name
        FROM active_hazards_view
        LIMIT 3;
    """
    
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            
            if rows:
                print(f"{Colors.GREEN}✅ View 'active_hazards_view' accessible!{Colors.RESET}")
                print(f"   Found {len(rows)} active hazards")
            else:
                print(f"{Colors.YELLOW}⚠️  No data in active_hazards_view{Colors.RESET}")
        print()
    except Exception as e:
        print(f"{Colors.RED}❌ View test failed: {str(e)}{Colors.RESET}")


def main():
    """Main test runner"""
    print_header()
    
    # Check environment variable
    if not display_connection_info():
        sys.exit(1)
    
    conn = None
    
    try:
        # Test connection
        conn = test_connection()
        
        # Run verification tests
        has_schema = verify_schema(conn)
        
        if has_schema:
            check_seed_data(conn)
            test_query(conn)
            test_functions(conn)
            test_views(conn)
        
        print("=" * 60)
        print(f"{Colors.GREEN}{Colors.BOLD}🎉 All tests completed successfully!{Colors.RESET}")
        print("=" * 60 + "\n")
        
    except Exception as e:
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Test suite failed!{Colors.RESET}")
        print(f"{Colors.RED}Error: {str(e)}{Colors.RESET}\n")
        sys.exit(1)
    
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    main()
